import { createActionSystem } from "@latticexyz/recs/deprecated";
import { Entity, getComponentValue, createIndexer, runQuery, HasValue, createWorld } from "@latticexyz/recs";
import { getNetworkConfig } from "./getNetworkConfig";
import { createPerlin } from "@latticexyz/noise";
import mudConfig from "@tenetxyz/world/mud.config";
import registryMudConfig from "@tenetxyz/registry/mud.config";
import { IWorld__factory } from "@tenetxyz/world/types/ethers-contracts/factories/IWorld__factory";
import { IWorld__factory as RegistryIWorld__factory } from "@tenetxyz/registry/types/ethers-contracts/factories/IWorld__factory";
import { awaitPromise, computedToStream, VoxelCoord, Coord, awaitStreamValue } from "@latticexyz/utils";
import { map, timer, combineLatest, BehaviorSubject, Subject, share } from "rxjs";
import { createPublicClient, fallback, webSocket, http, createWalletClient, Hex, parseEther, ClientConfig } from "viem";
import { createFaucetService } from "@latticexyz/services/faucet";
import { encodeEntity, syncToRecs, singletonEntity } from "@latticexyz/store-sync/recs";
import { SyncStep } from "@latticexyz/store-sync";
import { createBurnerAccount, createContract, transportObserver, ContractWrite } from "@latticexyz/common";
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
import { BaseCreationInWorld } from "../layers/react/components/RegisterCreation";
import { Engine } from "noa-engine";
import { setupComponentParsers } from "./componentParsers/componentParser";
import { createRelayStream } from "./createRelayStream";
import { ComputeNormalsBlock } from "@babylonjs/core";
import { BigNumber } from "ethers";

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
  const registryWorld = createWorld();
  const networkConfig = await getNetworkConfig(true);
  console.log("Got registry network config", networkConfig);

  const clientOptions = {
    chain: networkConfig.chain,
    transport: transportObserver(fallback([webSocket(), http()])),
    pollingInterval: 1000,
  } as const satisfies ClientConfig;

  const publicClient = createPublicClient(clientOptions);

  const { components, latestBlock$, blockStorageOperations$, waitForTransaction } = await syncToRecs({
    world: registryWorld,
    config: registryMudConfig,
    address: networkConfig.worldAddress as Hex,
    publicClient,
    startBlock: BigInt(networkConfig.initialBlockNumber),
    maxBlockRange: BigInt(100000),
  });

  return { registryComponents: components, registryResult: { components: components } };
};

export async function setupNetwork() {
  const { registryComponents, registryResult } = await setupWorldRegistryNetwork(); // load the registry world first so the transactionHash$ stream is subscribed to this world (at least this is what I think. I just know that if you place it after, transactions fail with: "you have the wrong abi" when calling systems)
  const world = createWorld();

  console.log("Getting network config...");
  const networkConfig = await getNetworkConfig(false);
  console.log("Got network config", networkConfig);

  const clientOptions = {
    chain: networkConfig.chain,
    transport: transportObserver(fallback([webSocket(), http()])),
    pollingInterval: 1000,
  } as const satisfies ClientConfig;

  const publicClient = createPublicClient(clientOptions);

  const burnerAccount = createBurnerAccount(networkConfig.privateKey as Hex);
  const burnerWalletClient = createWalletClient({
    ...clientOptions,
    account: burnerAccount,
  });

  const write$ = new Subject<ContractWrite>();
  const worldContract = createContract({
    address: networkConfig.worldAddress as Hex,
    abi: IWorld__factory.abi,
    publicClient,
    walletClient: burnerWalletClient,
    onWrite: (write) => write$.next(write),
  });

  const { components, blockLogsStorage$, latestBlock$, blockStorageOperations$, waitForTransaction } = await syncToRecs(
    {
      world,
      config: mudConfig,
      address: networkConfig.worldAddress as Hex,
      publicClient,
      startBlock: BigInt(networkConfig.initialBlockNumber),
      maxBlockRange: BigInt(100000),
    }
  );
  const contractComponents = components;

  // Relayer setup
  let relay: Awaited<ReturnType<typeof createRelayStream>> | undefined;
  try {
    relay =
      networkConfig.relayServiceUrl && burnerAccount.address
        ? await createRelayStream(burnerWalletClient, networkConfig.relayServiceUrl, burnerAccount.address)
        : undefined;
  } catch (e) {
    console.error(e);
  }

  relay && world.registerDisposer(relay.dispose);
  if (relay) console.info("[Relayer] Relayer connected: " + networkConfig.relayServiceUrl);

  // Request drip from faucet
  let faucet: any = undefined;
  if (networkConfig.faucetServiceUrl) {
    const address = burnerAccount.address;
    console.info("[Dev Faucet]: Player address -> ", address);

    faucet = createFaucetService(networkConfig.faucetServiceUrl);

    const requestDrip = async () => {
      const balance = await publicClient.getBalance({ address });
      console.info(`[Dev Faucet]: Player balance -> ${balance}`);
      const lowBalance = balance < parseEther("1");
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

  async function callSystem(tx: Promise<Hex>) {
    try {
      return await tx;
    } catch (err) {
      // These errors typically happen BEFORE the transaction is executed (mainly gas errors)
      console.error(`Transaction call failed: ${err}`);

      toast(`Transaction call failed: ${parseTxError(err)}`);
    }
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

  function getVoxelPreviewVariant(voxelBaseTypeId: VoxelBaseTypeId): VoxelVariantTypeId | undefined {
    const voxelTypeRecord = getComponentValue(registryComponents.VoxelTypeRegistry, voxelBaseTypeId as Entity);
    if (!voxelTypeRecord) {
      return undefined;
    }
    return voxelTypeRecord.previewVoxelVariantId;
  }

  function getVoxelTypePreviewUrl(voxelBaseTypeId: VoxelBaseTypeId): string | undefined {
    const previewVoxelVariant = getVoxelPreviewVariant(voxelBaseTypeId);
    return previewVoxelVariant && getVoxelIconUrl(previewVoxelVariant);
  }

  // --- API ------------------------------------------------------------------------

  const perlin = await createPerlin();

  const terrainContext = {
    Position: contractComponents.Position,
    VoxelType: contractComponents.VoxelType,
    world,
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
          player: burnerAccount.address,
        }),
        HasValue(contractComponents.VoxelType, {
          voxelTypeId: voxelBaseTypeId,
          voxelVariantId: EMPTY_BYTES_32,
        }),
      ]),
    ];
  };

  async function build(noa: Engine, voxelBaseTypeId: VoxelBaseTypeId, coord: VoxelCoord) {
    const voxelInstancesOfVoxelType = getOwnedEntiesOfType(voxelBaseTypeId);

    if (voxelInstancesOfVoxelType.length === 0) {
      toast(`cannot build since we couldn't find a voxel (that you own) for voxelBaseTypeId=${voxelBaseTypeId}`);
      return console.warn(`cannot find a voxel (that you own) for voxelBaseTypeId=${voxelBaseTypeId}`);
    }
    const voxelInstanceOfVoxelType = voxelInstancesOfVoxelType[0];
    const scaleAsHex = (voxelInstanceOfVoxelType as string).substring(0, 66);
    const entityId = "0x" + (voxelInstanceOfVoxelType as string).substring(66);
    const scaleAsNumber = parseInt(scaleAsHex.substring(2)); // remove the leading 0x
    if (scaleAsNumber !== getWorldScale(noa)) {
      toast(`you can only place this voxel on scale ${scaleAsNumber}`);
      return;
    }

    const preview: string = getVoxelTypePreviewUrl(voxelBaseTypeId) || "";
    const previewVoxelVariant = getVoxelPreviewVariant(voxelBaseTypeId);

    const newVoxelOfSameType = `${scaleAsHex}:${world.registerEntity()}` as Entity;

    const mindSelector = "0x00000000";
    const fighterMindSelector = "0xa303e6be";

    await callSystem(worldContract.write.build([scaleAsNumber, entityId, coord, mindSelector]));

    // actions.add({
    //   id: `build+${voxelCoordToString(coord)}` as Entity, // used so we don't send the same transaction twice
    //   metadata: {
    //     // metadata determines how the transaction dialog box appears in the bottom left corner
    //     actionType: "build",
    //     coord,
    //     preview,
    //   },
    //   requirement: () => true,
    //   components: {
    //     Position: contractComponents.Position,
    //     VoxelType: contractComponents.VoxelType,
    //     OwnedBy: contractComponents.OwnedBy, // I think it's needed cause we check to see if the owner owns the voxel we're placing
    //   },
    //   execute: () => {
    //     return callSystem("build", [scaleAsHex, entityId, coord, mindSelector, { gasLimit: 900_000_000 }]);
    //   },
    //   updates: () => [
    //     // commented cause we're in creative mode
    //     // {
    //     //   component: "OwnedBy",
    //     //   entity: entity,
    //     //   value: { value: SingletonID },
    //     // },
    //     {
    //       component: "Position",
    //       entity: newVoxelOfSameType,
    //       value: coord,
    //     },
    //     {
    //       component: "VoxelType",
    //       entity: newVoxelOfSameType,
    //       value: {
    //         voxelTypeId: voxelBaseTypeId,
    //         voxelVariantId: previewVoxelVariant,
    //       },
    //     },
    //   ],
    // });
  }

  async function mine(coord: VoxelCoord, scale: number) {
    const voxelTypeKey = getEcsVoxelTypeAtPosition(coord, scale) ?? getTerrainVoxelTypeAtPosition(coord, scale);

    if (voxelTypeKey == null) {
      throw new Error("entity has no VoxelType");
    }
    const voxel = getEntityAtPosition(coord, scale);
    const airEntity = `${to64CharAddress("0x" + scale.toString())}:${world.registerEntity()}` as Entity;

    console.log(coord);

    await callSystem(worldContract.write.mine([voxelTypeKey.voxelBaseTypeId, coord]));
    // actions.add({
    //   id: `mine+${coord.x}/${coord.y}/${coord.z}` as Entity,
    //   metadata: { actionType: "mine", coord, voxelVariantTypeId: voxelTypeKey.voxelVariantTypeId },
    //   requirement: () => true,
    //   components: {
    //     Position: contractComponents.Position,
    //     OwnedBy: contractComponents.OwnedBy,
    //     VoxelType: contractComponents.VoxelType,
    //   },
    //   execute: () => {
    //     return callSystem(worldContract.write.mine(voxelTypeKey.voxelBaseTypeId, coord));
    //   },
    //   updates: () => [
    //     {
    //       component: "Position",
    //       entity: airEntity,
    //       value: coord,
    //     },
    //     {
    //       component: "VoxelType",
    //       entity: airEntity,
    //       value: {
    //         voxelTypeId: AIR_ID,
    //         voxelVariantId: AIR_ID,
    //       },
    //     },
    //     {
    //       component: "Position",
    //       entity: voxel || (Number.MAX_SAFE_INTEGER.toString() as Entity),
    //       value: null,
    //     },
    //   ],
    // });
  }

  // needed in creative mode, to give the user new voxels
  async function giftVoxel(voxelTypeId: string, preview: string) {
    const newVoxel = world.registerEntity();

    await callSystem(worldContract.write.giftVoxel([voxelTypeId]));

    // actions.add({
    //   id: `GiftVoxel+${voxelTypeId}` as Entity,
    //   metadata: { actionType: "giftVoxel", preview },
    //   requirement: () => true,
    //   components: {
    //     OwnedBy: contractComponents.OwnedBy,
    //     VoxelType: contractComponents.VoxelType,
    //   },
    //   execute: () => {
    //     return callSystem("giftVoxel", [voxelTypeId, { gasLimit: 10_000_000 }]);
    //   },
    //   updates: () => [
    //     // {
    //     //   component: "VoxelType",
    //     //   entity: newVoxel,
    //     //   value: {
    //     //     voxelTypeNamespace: voxelTypeNamespace,
    //     //     voxelTypeId: voxelTypeId,
    //     //     voxelVariantNamespace: "",
    //     //     voxelVariantId: "",
    //     //   },
    //     // },
    //     // {
    //     //   component: "OwnedBy",
    //     //   entity: newVoxel,
    //     //   value: { value: to64CharAddress(playerAddress) },
    //     // },
    //   ],
    // });
  }

  // needed in creative mode, to allow the user to remove voxels. Otherwise their inventory will fill up
  function removeVoxels(voxelBaseTypeIdAtSlot: VoxelBaseTypeId) {
    const voxels = getOwnedEntiesOfType(voxelBaseTypeIdAtSlot);
    if (voxels.length === 0) {
      return console.warn("trying to remove 0 voxels");
    }
    const voxelScales: string[] = [];
    const entityIds: string[] = [];
    for (let i = 0; i < voxels.length; i++) {
      const [voxelScale, entityId] = voxels[i].split(":");
      voxelScales.push(voxelScale);
      entityIds.push(entityId);
    }

    actions.add({
      id: `RemoveVoxels+VoxelType=${entityIds}` as Entity,
      metadata: {
        actionType: "removeVoxels",
        voxelVariantTypeId: getVoxelPreviewVariant(voxelBaseTypeIdAtSlot),
      },
      requirement: () => true,
      components: {
        OwnedBy: contractComponents.OwnedBy,
        VoxelType: contractComponents.VoxelType,
      },
      execute: () => {
        return callSystem("removeVoxels", [voxelScales, entityIds, { gasLimit: 10_000_000 }]);
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
    const coord = getComponentValue(contractComponents.Position, entity) as VoxelCoord;

    const activateSelector = "0x00000000";
    const moveForwardSelector = "0x7c9a5247";

    actions.add({
      id: `activateVoxel+entity=${entity}` as Entity,
      metadata: { actionType: "activateVoxel", preview },
      requirement: () => true,
      components: {},
      execute: () => {
        return callSystem("activate", [
          voxelTypeKeyInMudTable.voxelTypeId,
          coord,
          activateSelector,
          { gasLimit: 900_000_000 },
        ]);
      },
      updates: () => [],
      txMayNotWriteToTable: true,
    });
  }

  function registerTruthTableClassifier(
    name: string,
    description: string,
    inputRows: BigNumber[],
    outputRows: BigNumber[],
    numInputBits: number,
    numOutputBits: number
  ) {
    // TODO: Replace Iron NFT with a an register symbol
    const preview = getNftStorageLink("bafkreidkik2uccshptqcskpippfotmusg7algnfh5ozfsga72xyfdrvacm");
    actions.add({
      id: `registerTruthTableClassifier+name=${name}` as Entity,
      metadata: { actionType: "registerTruthTableClassifier", preview },
      requirement: () => true,
      components: {},
      execute: () => {
        return callSystem("registerTruthTable", [
          name,
          description,
          inputRows,
          outputRows,
          numInputBits,
          numOutputBits,
          { gasLimit: 900_000_000 },
        ]);
      },
      updates: () => [],
      txMayNotWriteToTable: true,
    });
  }

  function classifyIfCreationSatisfiesTruthTable(
    booleanClassifierId: Entity,
    spawnId: Entity,
    interfaceVoxels: InterfaceVoxel[],
    onSuccessCallback: (res: string) => void
  ) {
    // TODO: Relpace Iron NFT with a an register symbol
    const preview = getNftStorageLink("bafkreidkik2uccshptqcskpippfotmusg7algnfh5ozfsga72xyfdrvacm");

    const inInterfaceVoxels = interfaceVoxels.filter((interfaceVoxel) => interfaceVoxel.name.startsWith("in"));
    const outInterfaceVoxels = interfaceVoxels.filter((interfaceVoxel) => interfaceVoxel.name.startsWith("out"));
    actions.add({
      id: `classifyIfCreationSatisfiesTruthTable+booleanClassifierId=${booleanClassifierId}+spawnId=${spawnId}` as Entity,
      metadata: { actionType: "cassifyIfCreationSatisfiesTruthTable", preview },
      requirement: () => true,
      components: {},
      execute: () => {
        return callSystem(
          "classifyIfCreationSatisfiesTruthTable",
          [booleanClassifierId, spawnId, inInterfaceVoxels, outInterfaceVoxels, { gasLimit: 900_000_000 }],
          undefined,
          onSuccessCallback
        );
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
  const intervalId = setInterval(async () => {
    try {
      const balance = BigNumber.from(await publicClient.getBalance({ address: burnerWalletClient.account.address }));
      balanceGwei$.next(balance.div(BigNumber.from(10).pow(9)).toNumber());
    } catch (error) {
      balanceGwei$.error(error);
    }
  }, 5000);
  world.registerDisposer(() => clearInterval(intervalId)); // This will clean up the interval when unsubscribed

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
      console.log("doneSyncing");
      doneSyncing$.next(true);
    }
  };
  // awaitStreamValue(
  //   registryResult.components.SyncProgress.update$,
  //   ({ value }) => value[0]?.step === SyncStep.LIVE
  // ).then(async () => {
  //   console.log("registrySynced");
  //   registrySynced = true;

  //   trySendDoneSyncing();
  // });

  registryResult.components.SyncProgress.update$.subscribe(({ value }) => {
    const syncStep = value[0]?.step;
    if (syncStep === SyncStep.LIVE) {
      console.log("registrySynced");
      registrySynced = true;

      trySendDoneSyncing();
    }
  });

  components.SyncProgress.update$.subscribe(({ value }) => {
    const syncStep = value[0]?.step;
    if (syncStep === SyncStep.LIVE) {
      console.log("contractsSynced");
      contractsSynced = true;
      trySendDoneSyncing();
    }
  });

  // awaitStreamValue(components.SyncProgress.update$, ({ value }) => value[0]?.step === SyncStep.LIVE).then(() => {
  //   console.log("contractsSynced");
  //   contractsSynced = true;
  //   trySendDoneSyncing();
  // });

  const { ParsedCreationRegistry, ParsedVoxelTypeRegistry, ParsedSpawn } = setupComponentParsers(
    world,
    registryResult,
    components,
    networkConfig.worldAddress
  );

  return {
    config: networkConfig,
    storeConfig: mudConfig,
    playerEntity: encodeEntity({ address: "address" }, { address: burnerWalletClient.account.address }),
    publicClient,
    walletClient: burnerWalletClient,
    latestBlock$,
    blockStorageOperations$,
    waitForTransaction,
    worldContract,
    write$: write$.asObservable().pipe(share()),
    components,
    contractComponents,
    registryComponents,
    parsedComponents: {
      ParsedCreationRegistry,
      ParsedVoxelTypeRegistry,
      ParsedSpawn,
    },
    world,
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
      registerTruthTableClassifier,
      classifyIfCreationSatisfiesTruthTable,
    },
    // dev: setupDevSystems(world, encoders as Promise<any>, systems),
    // dev: setupDevSystems(world),
    connectedAddress: burnerAccount.address,
    streams: { connectedClients$, balanceGwei$, doneSyncing$ },
    relay,
    faucet,
    worldAddress: networkConfig.worldAddress,
    getVoxelIconUrl,
    getVoxelTypePreviewUrl,
    getVoxelPreviewVariant,
    voxelTypes: {
      VoxelVariantIdToDef,
      VoxelVariantIndexToKey,
      VoxelVariantSubscriptions,
    },
  };
}
