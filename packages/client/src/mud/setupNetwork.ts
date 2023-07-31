import { setupMUDV2Network, createActionSystem } from "@latticexyz/std-client";
import { Entity, getComponentValue, createIndexer, runQuery, HasValue, createWorld } from "@latticexyz/recs";
import {
  createFastTxExecutor,
  createFaucetService,
  getSnapSyncRecords,
  createRelayStream,
  SyncState,
} from "@latticexyz/network";
import { getNetworkConfig } from "./getNetworkConfig";
import { defineContractComponents } from "./contractComponents";
import { defineContractComponents as defineRegistryContractComponents } from "@tenetxyz/registry/client/contractComponents";
import { createPerlin } from "@latticexyz/noise";
import { BigNumber, Contract, Signer, utils } from "ethers";
import { JsonRpcProvider } from "@ethersproject/providers";
import { IWorld__factory } from "@tenetxyz/contracts/types/ethers-contracts/factories/IWorld__factory";
import { IWorld__factory as RegistryIWorld__factory } from "@tenetxyz/registry/types/ethers-contracts/factories/IWorld__factory";
import { getTableIds, awaitPromise, computedToStream, VoxelCoord, Coord, awaitStreamValue } from "@latticexyz/utils";
import { map, timer, combineLatest, BehaviorSubject } from "rxjs";
import storeConfig from "@tenetxyz/contracts/mud.config";
import registryStoreConfig from "@tenetxyz/registry/mud.config";
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
  VoxelVariantIdToDefMap,
  VoxelTypeKey,
  VoxelVariantNoaDef,
  voxelTypeToEntity,
  VoxelBaseTypeId,
  InterfaceVoxel,
  VoxelVariantTypeId,
  VoxelTypeKeyInMudTable,
  EMPTY_BYTES_32,
} from "../layers/noa/types";
import { Textures, UVWraps } from "../layers/noa/constants";
import {
  AIR_ID,
  BEDROCK_ID,
  DIRT_ID,
  GRASS_ID,
  TILE1_ID,
  TILE3_ID,
  TILE4_ID,
  TILE5_ID,
} from "../layers/network/api/terrain/occurrence";
import { getNftStorageLink } from "../layers/noa/constants";
import { getWorldScale, voxelCoordToString } from "../utils/coord";
import { toast } from "react-toastify";
import { abiDecode } from "../utils/abi";
import { BaseCreationInWorld } from "../layers/react/components/RegisterCreation";
import { getLiveStoreCache } from "./setupLiveStoreCache";
import { Engine } from "noa-engine";

export type SetupNetworkResult = Awaited<ReturnType<typeof setupNetwork>>;

export type VoxelVariantSubscription = (
  voxelVariantTypeId: VoxelVariantTypeId,
  voxelVariantNoaDef: VoxelVariantNoaDef
) => void;

const giveComponentsAHumanReadableId = (contractComponents: any) => {
  Object.entries(contractComponents).forEach(([name, component]) => {
    (component as any).id = name;
  });
};

const setupWorldRegistryNetwork = async () => {
  const params = new URLSearchParams(window.location.search);
  const registryWorld = createWorld();
  const registryComponents = defineRegistryContractComponents(registryWorld);
  giveComponentsAHumanReadableId(registryComponents);

  const networkConfig = await getNetworkConfig(true);
  networkConfig.showInDevTools = false;

  const result = await setupMUDV2Network<typeof registryComponents, typeof registryStoreConfig>({
    networkConfig,
    world: registryWorld,
    contractComponents: registryComponents,
    syncThread: "main", // PERF: sync using workers
    storeConfig: registryStoreConfig,
    worldAbi: RegistryIWorld__factory.abi,
    useABIInDevTools: false,
  });
  result.startSync();
  return { registryComponents, registryResult: result };
};

export async function setupNetwork() {
  const { registryComponents, registryResult } = await setupWorldRegistryNetwork(); // load the registry world first so the transactionHash$ stream is subscribed to this world (at least this is what I think. I just know that if you place it after, transactions fail with: "you have the wrong abi" when calling systems)
  const world = createWorld();
  const contractComponents = defineContractComponents(world);
  giveComponentsAHumanReadableId(contractComponents);

  console.log("Getting network config...");
  const networkConfig = await getNetworkConfig(false);
  networkConfig.showInDevTools = true;
  console.log("Got network config", networkConfig);
  const result = await setupMUDV2Network<typeof contractComponents, typeof storeConfig>({
    networkConfig,
    world,
    contractComponents,
    syncThread: "main", // PERF: sync using workers
    storeConfig,
    worldAbi: IWorld__factory.abi,
    useABIInDevTools: true,
  });
  console.log("Setup MUD V2 network", result);

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
  // Note: The check for signer?.provider instanceof JsonRpcProvider was removed because Vite build changes the name
  // of the instance. And they don't have a solution yet. Tracked here: https://github.com/vitejs/vite/issues/9528
  const fastTxExecutor = signer?.provider
    ? await createFastTxExecutor(signer as Signer & { provider: JsonRpcProvider })
    : null;

  // TODO: infer this from fastTxExecute signature?
  type BoundFastTxExecuteFn<C extends Contract> = <F extends keyof C>(
    func: F,
    args: Parameters<C[F]>,
    options?: {
      retryCount?: number;
    }
  ) => Promise<{ hash: string; tx: ReturnType<C[F]> }>;

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
  // please use callSystem instead because it handles errors better, haldes awaiting for the tx to finish, and handles callbacks for the system when it finishes
  const worldSend: BoundFastTxExecuteFn<WorldContract> = bindFastTxExecute(worldContract);

  async function callSystem<F extends keyof WorldContract>(
    func: F,
    args: Parameters<WorldContract[F]>,
    options?: {
      retryCount?: number;
    },
    onSuccessCallback?: (res: string) => void // This callback will be called with the result of the transaction
  ) {
    try {
      const { hash, tx } = await worldSend(func, args, options);
      if (onSuccessCallback) {
        transactionCallbacks.set(hash, onSuccessCallback);
      }
      return tx;
    } catch (err) {
      // These errors typically happen BEFORE the transaction is executed (mainly gas errors)
      console.error(`Transaction call failed: ${err}`);

      toast(`Transaction call failed: ${parseTxError(err)}`);
    }
  }

  const parseTxError = (err: any): string => {
    const defaultError = "couldn't parse error. See console for more info";

    if (!err) return defaultError;

    try {
      const errorBody = JSON.parse(err.body);
      const parsedError = errorBody?.error?.message;
      return parsedError || defaultError;
    } catch (err) {
      console.warn("couldn't parse error body parseError=", err);
      return defaultError;
    }
  };

  // --- ACTION SYSTEM --------------------------------------------------------------
  const actions = createActionSystem<{
    actionType: string;
    coord?: VoxelCoord;
    voxelVariantTypeId?: VoxelVariantTypeId;
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

  const VoxelVariantIdToDef: VoxelVariantIdToDefMap = new Map();
  const VoxelVariantSubscriptions: VoxelVariantSubscription[] = [];
  // TODO: should load initial ones from chain too
  VoxelVariantIdToDef.set(AIR_ID, {
    noaBlockIdx: 0,
    noaVoxelDef: undefined,
  });
  VoxelVariantIdToDef.set(DIRT_ID, {
    noaBlockIdx: 1,
    noaVoxelDef: {
      type: NoaBlockType.BLOCK,
      material: Textures.Dirt,
      uvWrap: UVWraps.Dirt,
    },
  });
  VoxelVariantIdToDef.set(BEDROCK_ID, {
    noaBlockIdx: 2,
    noaVoxelDef: {
      type: NoaBlockType.BLOCK,
      material: Textures.Bedrock,
      uvWrap: UVWraps.Bedrock,
    },
  });
  VoxelVariantIdToDef.set(TILE1_ID, {
    noaBlockIdx: 3,
    noaVoxelDef: {
      type: NoaBlockType.MESH,
      material: Textures.Tile1,
      uvWrap: UVWraps.Tile1,
    },
  });
  VoxelVariantIdToDef.set(GRASS_ID, {
    noaBlockIdx: 4,
    noaVoxelDef: {
      type: NoaBlockType.BLOCK,
      material: [Textures.Grass, Textures.Dirt, Textures.GrassSide],
      uvWrap: UVWraps.Grass,
    },
  });
  VoxelVariantIdToDef.set(TILE3_ID, {
    noaBlockIdx: 5,
    noaVoxelDef: {
      type: NoaBlockType.BLOCK,
      material: Textures.Tile3,
      uvWrap: UVWraps.Tile3,
    },
  });
  VoxelVariantIdToDef.set(TILE4_ID, {
    noaBlockIdx: 6,
    noaVoxelDef: {
      type: NoaBlockType.BLOCK,
      material: Textures.Tile4,
      uvWrap: UVWraps.Tile4,
    },
  });
  VoxelVariantIdToDef.set(TILE5_ID, {
    noaBlockIdx: 7,
    noaVoxelDef: {
      type: NoaBlockType.BLOCK,
      material: Textures.Tile5,
      uvWrap: UVWraps.Tile5,
    },
  });

  const VoxelVariantIndexToKey: Map<number, VoxelVariantTypeId> = new Map();

  function voxelIndexSubscription(voxelVariantTypeId: VoxelVariantTypeId, voxelVariantNoaDef: VoxelVariantNoaDef) {
    VoxelVariantIndexToKey.set(voxelVariantNoaDef.noaBlockIdx, voxelVariantTypeId);
  }

  VoxelVariantSubscriptions.push(voxelIndexSubscription);

  // initial run
  for (const [voxelVariantTypeId, voxelVariantNoaDef] of VoxelVariantIdToDef.entries()) {
    voxelIndexSubscription(voxelVariantTypeId, voxelVariantNoaDef);
  }

  function getVoxelIconUrl(voxelVariantTypeId: VoxelVariantTypeId): string | undefined {
    const voxel = VoxelVariantIdToDef.get(voxelVariantTypeId)?.noaVoxelDef;
    if (!voxel) return undefined;
    return Array.isArray(voxel.material) ? voxel.material[0] : voxel.material;
  }

  function getVoxelPreviewVariant(VoxelBaseTypeId: VoxelBaseTypeId): VoxelVariantTypeId | undefined {
    const voxelTypeRecord = getComponentValue(registryComponents.VoxelTypeRegistry, VoxelBaseTypeId as Entity);
    if (!voxelTypeRecord) {
      return undefined;
    }
    return voxelTypeRecord.previewVoxelVariantId;
  }

  function getVoxelTypePreviewUrl(VoxelBaseTypeId: VoxelBaseTypeId): string | undefined {
    const previewVoxelVariant = getVoxelPreviewVariant(VoxelBaseTypeId);
    return previewVoxelVariant && getVoxelIconUrl(previewVoxelVariant);
  }

  // --- API ------------------------------------------------------------------------

  const perlin = await createPerlin();

  const liveStoreCache = getLiveStoreCache(result.storeCache);
  const terrainContext = {
    Position: contractComponents.Position,
    VoxelType: contractComponents.VoxelType,
    world,
    liveStoreCache,
  };

  function getTerrainVoxelTypeAtPosition(position: VoxelCoord, scale: number): VoxelTypeKey {
    return getTerrainVoxel(getTerrain(position, perlin), position, perlin, scale);
  }

  function getEcsVoxelTypeAtPosition(position: VoxelCoord, scale: number): VoxelTypeKey | undefined {
    return getEcsVoxelType(terrainContext, position, scale);
  }
  function getVoxelAtPosition(position: VoxelCoord, scale: number): VoxelTypeKey {
    return getVoxelAtPositionApi(terrainContext, perlin, position, scale);
  }
  function getEntityAtPosition(position: VoxelCoord, scale: number): Entity | undefined {
    return getEntityAtPositionApi(terrainContext, position, scale);
  }

  function getName(entity: Entity): string | undefined {
    return getComponentValue(contractComponents.Name, entity)?.value;
  }

  const getOwnedEntiesOfType = (voxelBaseTypeId: string) => {
    return [
      ...runQuery([
        HasValue(contractComponents.OwnedBy, {
          player: playerAddress,
        }),
        HasValue(contractComponents.VoxelType, {
          voxelTypeId: voxelBaseTypeId,
          voxelVariantId: EMPTY_BYTES_32,
        }), // TODO: is it ok to just look for one value in this column?
      ]),
    ];
  };

  function build(noa: Engine, voxelBaseTypeId: VoxelBaseTypeId, coord: VoxelCoord) {
    const voxelInstancesOfVoxelType = getOwnedEntiesOfType(voxelBaseTypeId);

    if (voxelInstancesOfVoxelType.length === 0) {
      toast(`cannot build since we couldn't find a voxel (that you own) for voxelBaseTypeId=${voxelBaseTypeId}`);
      return console.warn(`cannot find a voxel (that you own) for voxelBaseTypeId=${voxelBaseTypeId}`);
    }
    const voxelInstanceOfVoxelType = voxelInstancesOfVoxelType[0];
    const [scaleAsHex, entityId] = (voxelInstanceOfVoxelType as string).split(":");
    const scaleAsNumber = parseInt(scaleAsHex.substring(2)); // remove the leading 0x
    if (scaleAsNumber !== getWorldScale(noa)) {
      toast(`you can only place this voxel on scale ${scaleAsNumber}`);
      return;
    }

    const preview: string = getVoxelTypePreviewUrl(voxelBaseTypeId) || "";
    const previewVoxelVariant = getVoxelPreviewVariant(voxelBaseTypeId);

    const newVoxelOfSameType = `${scaleAsHex}:${world.registerEntity()}` as Entity;

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
        return callSystem("build", [scaleAsHex, entityId, coord, { gasLimit: 900_000_000 }]);
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
            voxelTypeId: voxelBaseTypeId,
            voxelVariantId: previewVoxelVariant,
          },
        },
      ],
    });
  }

  async function mine(coord: VoxelCoord, scale: number) {
    const voxelTypeKey = getEcsVoxelTypeAtPosition(coord, scale) ?? getTerrainVoxelTypeAtPosition(coord, scale);

    if (voxelTypeKey == null) {
      throw new Error("entity has no VoxelType");
    }
    const voxel = getEntityAtPosition(coord, scale);
    const airEntity = `${to64CharAddress("0x" + scale.toString())}:${world.registerEntity()}` as Entity;

    actions.add({
      id: `mine+${coord.x}/${coord.y}/${coord.z}` as Entity,
      metadata: { actionType: "mine", coord, voxelVariantTypeId: voxelTypeKey.voxelVariantTypeId },
      requirement: () => true,
      components: {
        Position: contractComponents.Position,
        OwnedBy: contractComponents.OwnedBy,
        VoxelType: contractComponents.VoxelType,
      },
      execute: () => {
        return callSystem("mine", [voxelTypeKey.voxelBaseTypeId, coord, { gasLimit: 900_000_000 }]);
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
            voxelTypeId: AIR_ID,
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
  function giftVoxel(voxelTypeId: string, preview: string) {
    const newVoxel = world.registerEntity();

    actions.add({
      id: `GiftVoxel+${voxelTypeId}` as Entity,
      metadata: { actionType: "giftVoxel", preview },
      requirement: () => true,
      components: {
        OwnedBy: contractComponents.OwnedBy,
        VoxelType: contractComponents.VoxelType,
      },
      execute: () => {
        return callSystem("giftVoxel", [voxelTypeId, { gasLimit: 10_000_000 }]);
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
  function removeVoxels(voxelBaseTypeIdAtSlot: Entity) {
    const voxels = getOwnedEntiesOfType(voxelBaseTypeIdAtSlot);
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
        return callSystem("removeVoxels", [
          voxels.map((voxelId) => to64CharAddress(voxelId)),
          { gasLimit: 10_000_000 },
        ]);
      },
      updates: () => [],
    });
  }

  function registerCreation(
    creationName: string,
    creationDescription: string,
    voxels: Entity[],
    baseCreationsInWorld: BaseCreationInWorld[]
  ) {
    // TODO: Replace Diamond NFT with a creation symbol
    const preview = getNftStorageLink("bafkreicro56v6rinwnltbkyjfzqdwva2agtrtypwaeowud447louxqgl5y");
    const voxelEntities = voxels.map((voxelEntityKey) => {
      const voxelCompositeKey = voxelEntityKey.split(":");
      return {
        scale: Number(voxelCompositeKey[0]),
        entityId: voxelCompositeKey[1],
      };
    });

    actions.add({
      id: `RegisterCreation+${creationName}` as Entity,
      metadata: { actionType: "registerCreation", preview },
      requirement: () => true,
      components: {
        OwnedBy: contractComponents.OwnedBy,
      },
      execute: () => {
        return callSystem("registerCreation", [
          creationName,
          creationDescription,
          voxelEntities,
          baseCreationsInWorld,
          { gasLimit: 900_000_000 },
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
        return callSystem("spawn", [lowerSouthWestCorner, creationId, { gasLimit: 900_000_000 }]);
      },
      updates: () => [],
    });
  }

  function classifyCreation(
    classifierId: Entity,
    spawnId: Entity,
    interfaceVoxels: InterfaceVoxel[],
    onSuccessCallback: (res: string) => void
  ) {
    // TODO: Relpace Iron NFT with a spawn symbol
    const preview = getNftStorageLink("bafkreidkik2uccshptqcskpippfotmusg7algnfh5ozfsga72xyfdrvacm");

    actions.add({
      id: `classifyCreation+classifier=${classifierId}+spawnId=${spawnId}+interfaceVoxels=${interfaceVoxels.toString()}` as Entity,
      metadata: { actionType: "classifyCreation", preview },
      requirement: () => true,
      components: {},
      execute: () => {
        return callSystem(
          "classify",
          [classifierId, spawnId, interfaceVoxels, { gasLimit: 900_000_000 }],
          undefined,
          onSuccessCallback
        );
      },
      updates: () => [],
      awaitConfirmation: true,
    });
  }

  function activate(entity: Entity) {
    const voxelTypeKeyInMudTable = getComponentValue(contractComponents.VoxelType, entity) as VoxelTypeKeyInMudTable;
    const preview = getVoxelTypePreviewUrl(voxelTypeKeyInMudTable.voxelVariantId);
    const [scaleAsHex, entityId] = (entity as string).split(":");

    actions.add({
      id: `activateVoxel+entity=${entity}` as Entity,
      metadata: { actionType: "activateVoxel", preview },
      requirement: () => true,
      components: {},
      execute: () => {
        return callSystem("activateVoxel", [scaleAsHex, entityId, { gasLimit: 900_000_000 }]);
      },
      updates: () => [],
      txMayNotWriteToTable: true,
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

  // wait until both the registry and contracts world are done syncing. Tnen send the live event
  const doneSyncing$ = new BehaviorSubject<boolean>(false);
  let contractsSynced = false;
  let registrySynced = false;
  const trySendDoneSyncing = () => {
    if (contractsSynced && registrySynced) {
      doneSyncing$.next(true);
    }
  };
  awaitStreamValue(result.components.LoadingState.update$, ({ value }) => value[0]?.state === SyncState.LIVE).then(
    () => {
      contractsSynced = true;
      trySendDoneSyncing();
    }
  );
  awaitStreamValue(
    registryResult.components.LoadingState.update$,
    ({ value }) => value[0]?.state === SyncState.LIVE
  ).then(() => {
    registrySynced = true;
    trySendDoneSyncing();
  });

  // please don't remove. This is for documentation purposes
  const internalMudWorldAndStoreComponents = result.components;

  return {
    ...result,
    contractComponents,
    registryComponents,
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
    streams: { connectedClients$, balanceGwei$, doneSyncing$ },
    config: networkConfig,
    relay,
    faucet,
    worldAddress: networkConfig.worldAddress,
    uniqueWorldId,
    getVoxelIconUrl,
    getVoxelTypePreviewUrl,
    getVoxelPreviewVariant,
    voxelTypes: {
      VoxelVariantIdToDef,
      VoxelVariantIndexToKey,
      VoxelVariantSubscriptions,
    },
    objectStore: { transactionCallbacks }, // stores global objects. These aren't components since they don't really fit in with the rxjs event-based system
    liveStoreCache,
  };
}
