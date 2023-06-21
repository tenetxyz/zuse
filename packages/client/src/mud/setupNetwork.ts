import { setupMUDV2Network, createActionSystem } from "@latticexyz/std-client";
import {
  Entity,
  getComponentValue,
  createIndexer,
  runQuery,
  HasValue,
} from "@latticexyz/recs";
import {
  createFastTxExecutor,
  createFaucetService,
  getSnapSyncRecords,
  createRelayStream,
} from "@latticexyz/network";
import { getNetworkConfig } from "./getNetworkConfig";
import { defineContractComponents } from "./contractComponents";
import { world } from "./world";
import { createPerlin } from "@latticexyz/noise";
import { BigNumber, Contract, Signer, utils } from "ethers";
import { JsonRpcProvider } from "@ethersproject/providers";
import { IWorld__factory } from "@tenetxyz/contracts/types/ethers-contracts/factories/IWorld__factory";
import {
  getTableIds,
  awaitPromise,
  computedToStream,
  VoxelCoord,
  Coord,
} from "@latticexyz/utils";
import { map, timer, combineLatest, BehaviorSubject } from "rxjs";
import storeConfig from "@tenetxyz/contracts/mud.config";
import {
  VoxelTypeIdToKey,
  VoxelTypeKey,
  VoxelTypeKeyToId,
} from "../layers/network/constants";
import {
  getEcsVoxelType,
  getTerrain,
  getTerrainVoxel,
  getVoxelAtPosition as getVoxelAtPositionApi,
  getEntityAtPosition as getEntityAtPositionApi,
} from "../layers/network/api";
import { to64CharAddress } from "../utils/entity";
import { SingletonID } from "@latticexyz/network";

export type SetupNetworkResult = Awaited<ReturnType<typeof setupNetwork>>;

export async function setupNetwork() {
  const contractComponents = defineContractComponents(world);

  // Give components a Human-readable ID
  Object.entries(contractComponents).forEach(([name, component]) => {
    component.id = name;
  });

  const networkConfig = await getNetworkConfig();
  const result = await setupMUDV2Network<
    typeof contractComponents,
    typeof storeConfig
  >({
    networkConfig,
    world,
    contractComponents,
    syncThread: "main",
    storeConfig,
    worldAbi: IWorld__factory.abi,
  });

  const signer = result.network.signer.get();
  const playerAddress = result.network.connectedAddress.get();

  // Relayer setup
  let relay: Awaited<ReturnType<typeof createRelayStream>> | undefined;
  try {
    relay =
      networkConfig.relayServiceUrl && playerAddress && signer
        ? await createRelayStream(
            signer,
            networkConfig.relayServiceUrl,
            playerAddress
          )
        : undefined;
  } catch (e) {
    console.error(e);
  }

  relay && world.registerDisposer(relay.dispose);
  if (relay)
    console.info(
      "[Relayer] Relayer connected: " + networkConfig.relayServiceUrl
    );

  // Request drip from faucet
  let faucet: any = undefined;
  if (networkConfig.faucetServiceUrl && signer) {
    const address = await signer.getAddress();
    console.info("[Dev Faucet]: Player address -> ", address);

    faucet = createFaucetService(networkConfig.faucetServiceUrl);

    const requestDrip = async () => {
      const balance = await signer.getBalance();
      console.info(`[Dev Faucet]: Player balance -> ${balance}`);
      const lowBalance = balance?.lte(utils.parseEther("1"));
      if (lowBalance) {
        console.info("[Dev Faucet]: Balance is low, dripping funds to player");
        // Double drip
        await faucet.dripDev({ address });
        await faucet.dripDev({ address });
      }
    };

    requestDrip();
    // Request a drip every 20 seconds
    setInterval(requestDrip, 20000);
  }

  // TODO: Uncomment once we support plugins
  // // Set initial component values
  // if (components.PluginRegistry.entities.length === 0) {
  //   addPluginRegistry("https://opcraft-plugins.mud.dev");
  // }
  // // Enable chat plugin by default
  // if (
  //   getEntitiesWithValue(components.Plugin, { host: "https://opcraft-plugins.mud.dev", path: "/chat.js" }).size === 0
  // ) {
  //   console.info("Enabling chat plugin by default");
  //   addPlugin({
  //     host: "https://opcraft-plugins.mud.dev",
  //     path: "/chat.js",
  //     active: true,
  //     source: "https://github.com/latticexyz/opcraft-plugins",
  //   });
  // }

  const provider = result.network.providers.get().json;
  const signerOrProvider = signer ?? provider;
  // Create a World contract instance
  const worldContract = IWorld__factory.connect(
    networkConfig.worldAddress,
    signerOrProvider
  );
  const uniqueWorldId = networkConfig.chainId + networkConfig.worldAddress;

  if (networkConfig.snapSync) {
    const currentBlockNumber = await provider.getBlockNumber();
    const tableRecords = await getSnapSyncRecords(
      networkConfig.worldAddress,
      getTableIds(storeConfig),
      currentBlockNumber,
      signerOrProvider
    );

    console.log(`Syncing ${tableRecords.length} records`);
    result.startSync(tableRecords, currentBlockNumber);
  } else {
    result.startSync();
  }

  // Create a fast tx executor
  const fastTxExecutor =
    signer?.provider instanceof JsonRpcProvider
      ? await createFastTxExecutor(
          signer as Signer & { provider: JsonRpcProvider }
        )
      : null;

  // TODO: infer this from fastTxExecute signature?
  type BoundFastTxExecuteFn<C extends Contract> = <F extends keyof C>(
    func: F,
    args: Parameters<C[F]>,
    options?: {
      retryCount?: number;
    }
  ) => Promise<ReturnType<C[F]>>;

  function bindFastTxExecute<C extends Contract>(
    contract: C
  ): BoundFastTxExecuteFn<C> {
    return async function (...args) {
      if (!fastTxExecutor) {
        throw new Error("no signer");
      }
      const { tx } = await fastTxExecutor.fastTxExecute(contract, ...args);
      return await tx;
    };
  }

  const worldSend = bindFastTxExecute(worldContract);

  // --- ACTION SYSTEM --------------------------------------------------------------
  const actions = createActionSystem<{
    actionType: string;
    coord?: VoxelCoord;
    voxelTypeKey?: VoxelTypeKey;
  }>(world, result.txReduced$);

  // Add optimistic updates and indexers
  const { withOptimisticUpdates } = actions;
  contractComponents.Position = createIndexer(
    withOptimisticUpdates(contractComponents.Position)
  );
  // Note: we don't add indexer to OwnedBy because there's current bugs with indexer in MUD 2
  // contractComponents.OwnedBy = createIndexer(
  //   withOptimisticUpdates(contractComponents.OwnedBy)
  // );
  contractComponents.OwnedBy = withOptimisticUpdates(
    contractComponents.OwnedBy
  );
  contractComponents.VoxelType = withOptimisticUpdates(
    contractComponents.VoxelType
  );

  // --- API ------------------------------------------------------------------------

  const perlin = await createPerlin();

  const terrainContext = {
    Position: contractComponents.Position,
    VoxelType: contractComponents.VoxelType,
    world,
  };

  function getTerrainVoxelTypeAtPosition(position: VoxelCoord): Entity {
    return getTerrainVoxel(getTerrain(position, perlin), position, perlin);
  }

  function getEcsVoxelTypeAtPosition(position: VoxelCoord): Entity | undefined {
    return getEcsVoxelType(terrainContext, position);
  }
  function getVoxelAtPosition(position: VoxelCoord): Entity {
    return getVoxelAtPositionApi(terrainContext, perlin, position);
  }
  function getEntityAtPosition(position: VoxelCoord): Entity | undefined {
    return getEntityAtPositionApi(terrainContext, position);
  }

  function getName(entity: Entity): string | undefined {
    return getComponentValue(contractComponents.Name, entity)?.value;
  }

  async function buildSystem(entity: Entity, coord: VoxelCoord) {
    const tx = await worldSend("tenet_BuildSystem_build", [
      to64CharAddress(entity),
      coord,
      { gasLimit: 5_000_000 },
    ]);
    return tx;
  }

  function build(voxelType: Entity, coord: VoxelCoord) {
    const voxelInstanceOfVoxelType = [
      ...runQuery([
        HasValue(contractComponents.OwnedBy, {
          value: to64CharAddress(playerAddress),
        }),
        HasValue(contractComponents.VoxelType, { value: voxelType }),
      ]),
    ][0];
    if (!voxelInstanceOfVoxelType) {
      return console.warn(
        `cannot find a voxel (that you own) for voxelType=${voxelType}`
      );
    }

    const voxelTypeKey = VoxelTypeIdToKey[voxelType as Entity];
    const newVoxelOfSameType = world.registerEntity();

    actions.add({
      id: `build+${coord.x}/${coord.y}/${coord.z}` as Entity, // used so we don't send the same transaction twice
      metadata: {
        // metadata determines how the transaction dialog box appears in the bottom left corner
        actionType: "build",
        coord,
        voxelTypeKey, // Determines the Icon that appears in the dialogue box
      },
      requirement: () => true,
      components: {
        Position: contractComponents.Position,
        VoxelType: contractComponents.VoxelType,
        OwnedBy: contractComponents.OwnedBy, // I think it's needed cause we check to see if the owner owns the voxel we're placing
      },
      execute: () => {
        return buildSystem(voxelInstanceOfVoxelType, coord);
      },
      updates: () => [
        // commented cause we're in creative mode
        // {
        //   component: "OwnedBy",
        //   entity: entity,
        //   value: { value: SingletonID },
        // },
        {
          component: "Position",
          entity: newVoxelOfSameType,
          value: coord,
        },
        {
          component: "VoxelType",
          entity: newVoxelOfSameType,
          value: { value: voxelType },
        },
      ],
    });
  }

  async function mineSystem(coord: VoxelCoord, voxel: Entity) {
    const tx = await worldSend("tenet_MineSystem_mine", [
      coord,
      voxel,
      { gasLimit: 5_000_000 },
    ]);
    return tx;
  }

  async function mine(coord: VoxelCoord) {
    const voxelType =
      getEcsVoxelTypeAtPosition(coord) ?? getTerrainVoxelTypeAtPosition(coord);

    if (voxelType == null) {
      throw new Error("entity has no VoxelType");
    }
    const voxelTypeKey = VoxelTypeIdToKey[voxelType];
    const voxel = getEntityAtPosition(coord);
    const airEntity = world.registerEntity();

    actions.add({
      id: `mine+${coord.x}/${coord.y}/${coord.z}` as Entity,
      metadata: { actionType: "mine", coord, voxelTypeKey },
      requirement: () => true,
      components: {
        Position: contractComponents.Position,
        OwnedBy: contractComponents.OwnedBy,
        VoxelType: contractComponents.VoxelType,
      },
      execute: () => {
        return mineSystem(coord, voxelType);
      },
      updates: () => [
        {
          component: "Position",
          entity: airEntity,
          value: coord,
        },
        {
          component: "VoxelType",
          entity: airEntity,
          value: { value: VoxelTypeKeyToId.Air },
        },
        {
          component: "Position",
          entity: voxel || (Number.MAX_SAFE_INTEGER.toString() as Entity),
          value: null,
        },
      ],
    });
  }

  // needed in creative mode, to give the user new voxels
  function giftVoxel(voxelType: Entity) {
    const newVoxel = world.registerEntity();
    const voxelTypeKey = VoxelTypeIdToKey[voxelType];

    actions.add({
      id: `GiftVoxel+${voxelType}` as Entity,
      metadata: { actionType: "giftVoxel", voxelTypeKey },
      requirement: () => true,
      components: {
        OwnedBy: contractComponents.OwnedBy,
        VoxelType: contractComponents.VoxelType,
      },
      execute: async () => {
        const tx = await worldSend("tenet_GiftVoxelSystem_giftVoxel", [
          voxelType,
          { gasLimit: 5_000_000 },
        ]);
      },
      updates: () => [
        {
          component: "VoxelType",
          entity: newVoxel,
          value: { value: voxelType },
        },
        {
          component: "OwnedBy",
          entity: playerAddress as Entity,
          value: newVoxel,
        },
      ],
    });
  }

  // needed in creative mode, to allow the user to remove voxels. Otherwise their inventory will fill up
  function removeVoxels(voxels: Entity[]) {
    if (voxels.length === 0) {
      return console.warn("trying to remove 0 voxels");
    }

    const voxelType = getComponentValue(contractComponents.VoxelType, voxels[0])
      ?.value as Entity;

    const voxelTypeKey = VoxelTypeIdToKey[voxelType];
    actions.add({
      id: `RemoveVoxel+${voxels.toString()}` as Entity,
      metadata: {
        actionType: "removeVoxels",
        voxelTypeKey,
      },
      requirement: () => true,
      components: {
        OwnedBy: contractComponents.OwnedBy,
        VoxelType: contractComponents.VoxelType,
      },
      execute: async () => {
        const tx = await worldSend("tenet_RemoveVoxelSystem_removeVoxels", [
          voxels.map((voxelId) => to64CharAddress(voxelId)),
          { gasLimit: 1_000_000 },
        ]);
      },
      updates: () => [],
    });
  }

  function registerCreation(
    creationName: string,
    creationDescription: string,
    voxels: Entity[]
  ) {
    const voxelTypeKey = "Diamond";

    actions.add({
      id: `RegisterCreation+${creationName}` as Entity,
      metadata: { actionType: "registerCreation", voxelTypeKey },
      requirement: () => true,
      components: {
        OwnedBy: contractComponents.OwnedBy,
      },
      execute: async () => {
        const tx = await worldSend("tenet_RegisterCreation_registerCreation", [
          creationName,
          creationDescription,
          voxels,
          { gasLimit: 5_000_000 },
        ]);
      },
      updates: () => [],
    });
  }

  function stake(chunkCoord: Coord) {
    return 0;
  }

  function claim(chunkCoord: Coord) {
    return 0;
  }

  // --- STREAMS --------------------------------------------------------------------
  const balanceGwei$ = new BehaviorSubject<number>(1);
  world.registerDisposer(
    combineLatest([timer(0, 5000), computedToStream(result.network.signer)])
      .pipe(
        map<[number, Signer | undefined], Promise<number>>(async ([, signer]) =>
          signer
            ? signer
                .getBalance()
                .then((v) => v.div(BigNumber.from(10).pow(9)).toNumber())
            : new Promise((res) => res(0))
        ),
        awaitPromise()
      )
      .subscribe(balanceGwei$)?.unsubscribe
  );

  const connectedClients$ = timer(0, 5000).pipe(
    map(async () => relay?.countConnected() || 0),
    awaitPromise()
  );

  return {
    ...result,
    contractComponents,
    world,
    worldContract,
    actions,
    api: {
      getTerrainVoxelTypeAtPosition,
      getEcsVoxelTypeAtPosition,
      getVoxelAtPosition,
      getEntityAtPosition,
      build,
      mine,
      giftVoxel,
      removeVoxels,
      registerCreation,
      stake,
      claim,
      getName,
    },
    worldSend: worldSend,
    fastTxExecutor,
    // dev: setupDevSystems(world, encoders as Promise<any>, systems),
    // dev: setupDevSystems(world),
    streams: { connectedClients$, balanceGwei$ },
    config: networkConfig,
    relay,
    faucet,
    worldAddress: networkConfig.worldAddress,
    uniqueWorldId,
    voxelTypes: { VoxelTypeIdToKey, VoxelTypeKeyToId },
  };
}
