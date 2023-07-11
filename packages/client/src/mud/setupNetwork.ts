import { setupMUDV2Network, createActionSystem } from "@latticexyz/std-client";
import { Entity, getComponentValue, createIndexer, runQuery, HasValue, Components } from "@latticexyz/recs";
import { createFastTxExecutor, createFaucetService, getSnapSyncRecords, createRelayStream } from "@latticexyz/network";
import { getNetworkConfig } from "./getNetworkConfig";
import { defineContractComponents } from "./contractComponents";
import { world } from "./world";
import { createPerlin } from "@latticexyz/noise";
import { BigNumber, Contract, Signer, utils } from "ethers";
import { JsonRpcProvider } from "@ethersproject/providers";
import { IWorld__factory } from "@tenetxyz/contracts/types/ethers-contracts/factories/IWorld__factory";
import { getTableIds, awaitPromise, computedToStream, VoxelCoord, Coord } from "@latticexyz/utils";
import { map, timer, combineLatest, BehaviorSubject } from "rxjs";
import storeConfig from "@tenetxyz/contracts/mud.config";
import {
  getEcsVoxelType,
  getTerrain,
  getTerrainVoxel,
  getVoxelAtPosition as getVoxelAtPositionApi,
  getEntityAtPosition as getEntityAtPositionApi,
} from "../layers/network/api";
import { to64CharAddress } from "../utils/entity";
import {
  NoaBlockType,
  VoxelVariantData,
  VoxelTypeDataKey,
  VoxelVariantDataKey,
  VoxelVariantDataValue,
  voxelVariantDataKeyToString,
  voxelVariantKeyStringToKey,
  voxelTypeToEntity,
  VoxelTypeBaseKey,
  voxelTypeBaseKeyStrToVoxelTypeRegistryKeyStr,
  voxelTypeToVoxelTypeBaseKey,
} from "../layers/noa/types";
import { Textures, UVWraps } from "../layers/noa/constants";
import { keccak256 } from "@latticexyz/utils";
import { TENET_NAMESPACE } from "../constants";
import { AIR_ID, BEDROCK_ID, DIRT_ID, GRASS_ID } from "../layers/network/api/terrain/occurrence";
import { getNftStorageLink } from "../layers/noa/constants";
import { voxelCoordToString } from "../utils/coord";
import { defaultAbiCoder } from "ethers/lib/utils";
import { toast } from "react-toastify";
import { abiDecode } from "../utils/abi";

export type SetupNetworkResult = Awaited<ReturnType<typeof setupNetwork>>;

export type VoxelVariantSubscription = (
  voxelVariantKey: VoxelVariantDataKey,
  voxelVariantData: VoxelVariantDataValue
) => void;

export async function setupNetwork() {
  const contractComponents = defineContractComponents(world);

  // Give components a Human-readable ID
  Object.entries(contractComponents).forEach(([name, component]) => {
    component.id = name;
  });

  const networkConfig = await getNetworkConfig();
  const result = await setupMUDV2Network<typeof contractComponents, typeof storeConfig>({
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
        ? await createRelayStream(signer, networkConfig.relayServiceUrl, playerAddress)
        : undefined;
  } catch (e) {
    console.error(e);
  }

  relay && world.registerDisposer(relay.dispose);
  if (relay) console.info("[Relayer] Relayer connected: " + networkConfig.relayServiceUrl);

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
  const worldContract = IWorld__factory.connect(networkConfig.worldAddress, signerOrProvider);
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
      ? await createFastTxExecutor(signer as Signer & { provider: JsonRpcProvider })
      : null;

  // TODO: infer this from fastTxExecute signature?
  type BoundFastTxExecuteFn<C extends Contract> = <F extends keyof C>(
    func: F,
    args: Parameters<C[F]>,
    options?: {
      retryCount?: number;
    }
  ) => Promise<ReturnType<C[F]>>;

  function bindFastTxExecute<C extends Contract>(contract: C): BoundFastTxExecuteFn<C> {
    return async function (...args) {
      if (!fastTxExecutor) {
        throw new Error("no signer");
      }
      return fastTxExecutor.fastTxExecute(contract, ...args);
    };
  }

  // TODO: if some transactions never finish, we may not evict them from this map.
  // I don't know the code enough to know if that's the case. we need to monitor this in the meantime
  const transactionCallbacks = new Map<string, (res: string) => void>();

  type WorldContract = typeof worldContract;

  async function callSystem<F extends keyof WorldContract>(
    func: F,
    args: Parameters<WorldContract[F]>,
    options?: {
      retryCount?: number;
    },
    onSuccessCallback?: (res: string) => void // This callback will be called with the result of the transaction
  ) {
    const worldSend: BoundFastTxExecuteFn<WorldContract> = bindFastTxExecute(worldContract);
    try {
      const res = await worldSend(func, args, options);
      const { hash, tx } = res;
      debugger;
      if (onSuccessCallback) {
        transactionCallbacks.set(hash, onSuccessCallback);
      }
      return tx;
    } catch (err) {
      // These errors typically happen BEFORE the transaction is executed (mainly gas errors)
      console.error(`Transaction call failed: ${err}`);

      // TODO: should we parse this message with big numbers in mind?
      const errorBody = JSON.parse(err.body);

      let error = errorBody?.error?.message;
      if (!error) {
        error = "couldn't parse error. See console for more info";
      }

      toast(`Transaction call failed: ${error}`);
    }
  }

  // --- ACTION SYSTEM --------------------------------------------------------------
  const actions = createActionSystem<{
    actionType: string;
    coord?: VoxelCoord;
    voxelVariantKey?: VoxelVariantDataKey;
    preview?: string;
  }>(world, result.txReduced$);

  // Add optimistic updates and indexers
  const { withOptimisticUpdates } = actions;
  contractComponents.Position = createIndexer(withOptimisticUpdates(contractComponents.Position));
  // Note: we don't add indexer to OwnedBy because there's current bugs with indexer in MUD 2
  // contractComponents.OwnedBy = createIndexer(
  //   withOptimisticUpdates(contractComponents.OwnedBy)
  // );
  contractComponents.OwnedBy = withOptimisticUpdates(contractComponents.OwnedBy);
  contractComponents.VoxelType = withOptimisticUpdates(contractComponents.VoxelType);

  const VoxelVariantData: VoxelVariantData = new Map();
  const VoxelVariantDataSubscriptions: VoxelVariantSubscription[] = [];
  // TODO: should load initial ones from chain too
  VoxelVariantData.set(
    voxelVariantDataKeyToString({
      voxelVariantNamespace: TENET_NAMESPACE,
      voxelVariantId: AIR_ID,
    }),
    {
      index: 0,
      data: undefined,
    }
  );
  VoxelVariantData.set(
    voxelVariantDataKeyToString({
      voxelVariantNamespace: TENET_NAMESPACE,
      voxelVariantId: DIRT_ID,
    }),
    {
      index: 1,
      data: {
        type: NoaBlockType.BLOCK,
        material: Textures.Dirt,
        uvWrap: UVWraps.Dirt,
      },
    }
  );
  VoxelVariantData.set(
    voxelVariantDataKeyToString({
      voxelVariantNamespace: TENET_NAMESPACE,
      voxelVariantId: GRASS_ID,
    }),
    {
      index: 2,
      data: {
        type: NoaBlockType.BLOCK,
        material: [Textures.Grass, Textures.Dirt, Textures.GrassSide],
        uvWrap: UVWraps.Grass,
      },
    }
  );
  VoxelVariantData.set(
    voxelVariantDataKeyToString({
      voxelVariantNamespace: TENET_NAMESPACE,
      voxelVariantId: BEDROCK_ID,
    }),
    {
      index: 3,
      data: {
        type: NoaBlockType.BLOCK,
        material: Textures.Bedrock,
        uvWrap: UVWraps.Bedrock,
      },
    }
  );

  const VoxelVariantIndexToKey: Map<number, VoxelVariantDataKey> = new Map();

  function voxelIndexSubscription(voxelVariantKey: VoxelVariantDataKey, voxelVariantData: VoxelVariantDataValue) {
    VoxelVariantIndexToKey.set(voxelVariantData.index, voxelVariantKey);
  }

  VoxelVariantDataSubscriptions.push(voxelIndexSubscription);

  // initial run
  for (const [voxelVariantKey, voxelVariantData] of VoxelVariantData.entries()) {
    voxelIndexSubscription(voxelVariantKeyStringToKey(voxelVariantKey), voxelVariantData);
  }

  function getVoxelIconUrl(voxelTypeKey: VoxelVariantDataKey): string | undefined {
    const voxel = VoxelVariantData.get(voxelVariantDataKeyToString(voxelTypeKey))?.data;
    if (!voxel) return undefined;
    return Array.isArray(voxel.material) ? voxel.material[0] : voxel.material;
  }

  function getVoxelPreviewVariant(voxelTypeBaseKey: VoxelTypeBaseKey): VoxelVariantDataKey | undefined {
    const voxelTypeRegistryKey = voxelTypeBaseKeyStrToVoxelTypeRegistryKeyStr(voxelTypeBaseKey) as Entity;
    const voxelTypeRecord = getComponentValue(contractComponents.VoxelTypeRegistry, voxelTypeRegistryKey);
    return (
      voxelTypeRecord && {
        voxelVariantNamespace: voxelTypeRecord.previewVoxelVariantNamespace,
        voxelVariantId: voxelTypeRecord.previewVoxelVariantId,
      }
    );
  }

  function getVoxelTypePreviewUrl(voxelTypeBaseKey: VoxelTypeBaseKey): string | undefined {
    const previewVoxelVariant = getVoxelPreviewVariant(voxelTypeBaseKey);
    return previewVoxelVariant && getVoxelIconUrl(previewVoxelVariant);
  }

  // --- API ------------------------------------------------------------------------

  const perlin = await createPerlin();

  const terrainContext = {
    Position: contractComponents.Position,
    VoxelType: contractComponents.VoxelType,
    world,
  };

  function getTerrainVoxelTypeAtPosition(position: VoxelCoord): VoxelTypeDataKey {
    return getTerrainVoxel(getTerrain(position, perlin), position, perlin);
  }

  function getEcsVoxelTypeAtPosition(position: VoxelCoord): VoxelTypeDataKey | undefined {
    return getEcsVoxelType(terrainContext, position);
  }
  function getVoxelAtPosition(position: VoxelCoord): VoxelTypeDataKey {
    return getVoxelAtPositionApi(terrainContext, perlin, position);
  }
  function getEntityAtPosition(position: VoxelCoord): Entity | undefined {
    return getEntityAtPositionApi(terrainContext, position);
  }

  function getName(entity: Entity): string | undefined {
    return getComponentValue(contractComponents.Name, entity)?.value;
  }

  function build(voxelType: VoxelTypeBaseKey, coord: VoxelCoord) {
    const voxelInstanceOfVoxelType = [
      ...runQuery([
        HasValue(contractComponents.OwnedBy, {
          value: to64CharAddress(playerAddress),
        }),
        HasValue(contractComponents.VoxelType, voxelType),
      ]),
    ][0];
    if (!voxelInstanceOfVoxelType) {
      return console.warn(`cannot find a voxel (that you own) for voxelType=${voxelType}`);
    }

    const preview: string = getVoxelTypePreviewUrl(voxelType) || "";
    const previewVoxelVariant = getVoxelPreviewVariant(voxelType);

    const newVoxelOfSameType = world.registerEntity();

    actions.add({
      id: `build+${voxelCoordToString(coord)}` as Entity, // used so we don't send the same transaction twice
      metadata: {
        // metadata determines how the transaction dialog box appears in the bottom left corner
        actionType: "build",
        coord,
        preview,
      },
      requirement: () => true,
      components: {
        Position: contractComponents.Position,
        VoxelType: contractComponents.VoxelType,
        OwnedBy: contractComponents.OwnedBy, // I think it's needed cause we check to see if the owner owns the voxel we're placing
      },
      execute: () => {
        return callSystem("tenet_BuildSystem_build", [
          to64CharAddress(voxelInstanceOfVoxelType),
          coord,
          { gasLimit: 100_000_000 },
        ]);
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
          value: {
            voxelTypeNamespace: voxelType.voxelTypeNamespace,
            voxelTypeId: voxelType.voxelTypeId,
            voxelVariantNamespace: previewVoxelVariant?.voxelVariantNamespace,
            voxelVariantId: previewVoxelVariant?.voxelVariantId,
          },
        },
      ],
    });
  }

  async function mine(coord: VoxelCoord) {
    const voxelTypeKey = getEcsVoxelTypeAtPosition(coord) ?? getTerrainVoxelTypeAtPosition(coord);

    if (voxelTypeKey == null) {
      throw new Error("entity has no VoxelType");
    }
    const voxel = getEntityAtPosition(coord);
    const airEntity = world.registerEntity();

    const voxelVariantKey: VoxelVariantDataKey = {
      voxelVariantNamespace: voxelTypeKey.voxelVariantNamespace,
      voxelVariantId: voxelTypeKey.voxelVariantId,
    };

    actions.add({
      id: `mine+${coord.x}/${coord.y}/${coord.z}` as Entity,
      metadata: { actionType: "mine", coord, voxelVariantKey },
      requirement: () => true,
      components: {
        Position: contractComponents.Position,
        OwnedBy: contractComponents.OwnedBy,
        VoxelType: contractComponents.VoxelType,
      },
      execute: () => {
        return callSystem("tenet_MineSystem_mine", [
          coord,
          voxelTypeKey.voxelTypeNamespace,
          voxelTypeKey.voxelTypeId,
          voxelTypeKey.voxelVariantNamespace,
          voxelTypeKey.voxelVariantId,
          { gasLimit: 100_000_000 },
        ]);
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
          value: {
            voxelTypeNamespace: TENET_NAMESPACE,
            voxelTypeId: AIR_ID,
            voxelVariantNamespace: TENET_NAMESPACE,
            voxelVariantId: AIR_ID,
          },
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
  function giftVoxel(voxelTypeNamespace: string, voxelTypeId: string, preview: string) {
    const newVoxel = world.registerEntity();

    actions.add({
      id: `GiftVoxel+${voxelTypeNamespace}+${voxelTypeId}` as Entity,
      metadata: { actionType: "giftVoxel", preview },
      requirement: () => true,
      components: {
        OwnedBy: contractComponents.OwnedBy,
        VoxelType: contractComponents.VoxelType,
      },
      execute: () => {
        return callSystem("tenet_GiftVoxelSystem_giftVoxel", [
          voxelTypeNamespace,
          voxelTypeId,
          { gasLimit: 10_000_000 },
        ]);
      },
      updates: () => [
        // {
        //   component: "VoxelType",
        //   entity: newVoxel,
        //   value: {
        //     voxelTypeNamespace: voxelTypeNamespace,
        //     voxelTypeId: voxelTypeId,
        //     voxelVariantNamespace: "",
        //     voxelVariantId: "",
        //   },
        // },
        // {
        //   component: "OwnedBy",
        //   entity: newVoxel,
        //   value: { value: to64CharAddress(playerAddress) },
        // },
      ],
    });
  }

  // needed in creative mode, to allow the user to remove voxels. Otherwise their inventory will fill up
  function removeVoxels(voxels: Entity[]) {
    if (voxels.length === 0) {
      return console.warn("trying to remove 0 voxels");
    }

    const voxelType = getComponentValue(contractComponents.VoxelType, voxels[0]);
    const voxelTypeKey = voxelType ? (voxelTypeToEntity(voxelType) as string) : "";
    actions.add({
      id: `RemoveVoxels+VoxelType=${voxelTypeKey}` as Entity,
      metadata: {
        actionType: "removeVoxels",
      },
      requirement: () => true,
      components: {
        OwnedBy: contractComponents.OwnedBy,
        VoxelType: contractComponents.VoxelType,
      },
      execute: () => {
        return callSystem("tenet_RmVoxelSystem_removeVoxels", [
          voxels.map((voxelId) => to64CharAddress(voxelId)),
          { gasLimit: 10_000_000 },
        ]);
      },
      updates: () => [],
    });
  }

  function registerCreation(creationName: string, creationDescription: string, voxels: Entity[]) {
    // TODO: Relpace Diamond NFT with a creation symbol
    const preview = getNftStorageLink("bafkreicro56v6rinwnltbkyjfzqdwva2agtrtypwaeowud447louxqgl5y");

    actions.add({
      id: `RegisterCreation+${creationName}` as Entity,
      metadata: { actionType: "registerCreation", preview },
      requirement: () => true,
      components: {
        OwnedBy: contractComponents.OwnedBy,
      },
      execute: () => {
        return callSystem("tenet_RegisterCreation_registerCreation", [
          creationName,
          creationDescription,
          voxels,
          { gasLimit: 30_000_000 },
        ]);
      },
      updates: () => [],
    });
  }

  function spawnCreation(lowerSouthWestCorner: VoxelCoord, creationId: Entity) {
    // TODO: Relpace Iron NFT with a spawn symbol
    const preview = getNftStorageLink("bafkreidkik2uccshptqcskpippfotmusg7algnfh5ozfsga72xyfdrvacm");

    actions.add({
      id: `SpawnCreation+${creationId}+at+${voxelCoordToString(lowerSouthWestCorner)}` as Entity,
      metadata: { actionType: "spawnCreation", preview },
      requirement: () => true,
      components: {},
      execute: () => {
        return callSystem("tenet_SpawnSystem_spawn", [lowerSouthWestCorner, creationId, { gasLimit: 100_000_000 }]);
      },
      updates: () => [],
    });
  }

  function classifyCreation(classifierId: Entity, spawnId: Entity, interfaceVoxels: Entity[]) {
    // TODO: Relpace Iron NFT with a spawn symbol
    const preview = getNftStorageLink("bafkreidkik2uccshptqcskpippfotmusg7algnfh5ozfsga72xyfdrvacm");

    actions.add({
      id: `classifyCreation+classifier=${classifierId}+spawnId=${spawnId}+interfaceVoxels=${interfaceVoxels.toString()}` as Entity,
      metadata: { actionType: "classifyCreation", preview },
      requirement: () => true,
      components: {},
      execute: () => {
        return callSystem("tenet_ClassifyCreation_classify", [
          classifierId,
          spawnId,
          // defaultAbiCoder.encode(["bytes32[]"], interfaceVoxels),
          interfaceVoxels,
          { gasLimit: 100_000_000 },
        ]);
      },
      updates: () => [],
    });
  }

  function activate(entity: Entity) {
    const voxelTypeObj = getComponentValue(contractComponents.VoxelType, entity);
    const preview = getVoxelTypePreviewUrl(voxelTypeObj as VoxelTypeBaseKey);

    actions.add({
      id: `activate+entity=${entity}` as Entity,
      metadata: { actionType: "activate", preview },
      requirement: () => true,
      components: {},
      execute: () => {
        return callSystem(
          "tenet_ActivateSystem_activate",
          [entity, { gasLimit: 100_000_000 }],
          undefined,
          (rawResponse) => {
            const response = abiDecode("string", rawResponse);
            if (response !== "") {
              toast(response);
            }
          }
        );
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
            ? signer.getBalance().then((v) => v.div(BigNumber.from(10).pow(9)).toNumber())
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

  // please don't remove. This is for documentation purposes
  const internalMudWorldAndStoreComponents = result.components;

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
      spawnCreation,
      classifyCreation,
      stake,
      claim,
      getName,
      activate,
    },
    fastTxExecutor,
    // dev: setupDevSystems(world, encoders as Promise<any>, systems),
    // dev: setupDevSystems(world),
    streams: { connectedClients$, balanceGwei$ },
    config: networkConfig,
    relay,
    faucet,
    worldAddress: networkConfig.worldAddress,
    uniqueWorldId,
    getVoxelIconUrl,
    getVoxelTypePreviewUrl,
    getVoxelPreviewVariant,
    voxelTypes: {
      VoxelVariantData,
      VoxelVariantIndexToKey,
      VoxelVariantDataSubscriptions,
    },
    objectStore: { transactionCallbacks }, // stores global objects. These aren't components since they don't really fit in with the rxjs event-based system
  };
}
