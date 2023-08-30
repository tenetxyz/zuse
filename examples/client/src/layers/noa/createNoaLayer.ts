import {
  createIndexer,
  getComponentValue,
  namespaceWorld,
  removeComponent,
  setComponent,
  updateComponent,
  createLocalCache,
  getEntitiesWithValue,
  runQuery,
  HasValue,
  Entity,
  getEntityString,
  getEntitySymbol,
} from "@latticexyz/recs";
import { awaitStreamValue, Coord, isNotEmpty, pickRandom, random, VoxelCoord } from "@latticexyz/utils";
import { NetworkLayer } from "../network";
import {
  definePlayerDirectionComponent,
  definePlayerPositionComponent,
  defineSelectedSlotComponent,
  defineCraftingTableComponent,
  defineUIComponent,
  definePlayerLastMessage,
  definePlayerRelayerChunkPositionComponent,
  defineLocalPlayerPositionComponent,
  defineTutorialComponent,
  definePreTeleportPositionComponent,
  defineSoundComponent,
  defineVoxelSelectionComponent,
  defineSpawnCreationComponent,
  defineSpawnInFocusComponent,
  defineFocusedUiComponent,
  defineSpawnToClassifyComponent,
  defineVoxelInterfaceSelectionComponent,
} from "./components";
import { CRAFTING_SIDE, EMPTY_CRAFTING_TABLE } from "./constants";
import * as BABYLON from "@babylonjs/core";
import { Texture, Vector4 } from "@babylonjs/core";
import { setupHand } from "./engine/hand";
import { monkeyPatchMeshComponent } from "./engine/components/monkeyPatchMeshComponent";
import { registerRotationComponent, registerTargetedRotationComponent } from "./engine/components/rotationComponent";
import { setupClouds, setupSky } from "./engine/sky";
import { setupNoaEngine } from "./setup";
import {
  createVoxelSystem,
  createVoxelVariantSystem,
  createActivateVoxelSystem,
  createInputSystem,
  createInventoryIndexSystem,
  createPlayerPositionSystem,
  createRelaySystem,
  createSoundSystem,
  createSyncLocalPlayerPositionSystem,
  createTutorialSystem,
} from "./systems";
import { registerHandComponent } from "./engine/components/handComponent";
import { registerModelComponent } from "./engine/components/modelComponent";
import { registerMiningVoxelComponent } from "./engine/components/miningVoxelComponent";
import { defineInventoryIndexComponent } from "./components/InventoryIndex";
import { setupDayNightCycle } from "./engine/dayNightCycle";
import { getNoaPositionStrict, setNoaPosition } from "./engine/components/utils";
import { registerTargetedPositionComponent } from "./engine/components/targetedPositionComponent";
import { defaultAbiCoder as abi, keccak256 } from "ethers/lib/utils";
import { getChunkCoord } from "../../utils/chunk";
import { BehaviorSubject, map, Subject, throttleTime, timer } from "rxjs";
// import { getStakeEntity } from "../../utils/stake"; // commented cause we aren't using it
import { createSpawnPlayerSystem } from "./systems/createSpawnPlayerSystem";
import { definePlayerMeshComponent } from "./components/PlayerMesh";
import { Engine } from "@babylonjs/core";
import { definePersistentNotificationComponent, NotificationIcon } from "./components/persistentNotification";
import { createVoxelSelectionOverlaySystem } from "./systems/createVoxelSelectionOverlaySystem";
import { createSpawnCreationOverlaySystem } from "./systems/createSpawnCreationOverlaySystem";
import { createSpawnOverlaySystem } from "./systems/createSpawnOverlaySystem";
import { VoxelVariantNoaDef, VoxelBaseTypeId, VoxelVariantTypeId } from "./types";
import { DEFAULT_BLOCK_TEST_DISTANCE } from "./setup/setupNoaEngine";
import { FocusedUiType } from "./components/FocusedUi";
import { defineWorldScaleComponent } from "./components/WorldScale";
import { SingletonID } from "@/constants";

export enum UiComponentType {
  INVENTORY = "Inventory",
  SIDEBAR = "Sidebar",
  WORLD = "World",
}

export function createNoaLayer(network: NetworkLayer) {
  const world = namespaceWorld(network.world, "noa");
  const {
    worldAddress,
    config: { chainId },
    streams: { doneSyncing$ },
    contractComponents: { VoxelType },
    voxelTypes: { VoxelVariantIdToDef, VoxelVariantSubscriptions },
    getVoxelPreviewVariant,
  } = network;
  const uniqueWorldId = chainId + worldAddress;

  const SingletonEntity = world.registerEntity({ id: SingletonID });

  // --- COMPONENTS -----------------------------------------------------------------
  const components = {
    SelectedSlot: defineSelectedSlotComponent(world),
    CraftingTable: defineCraftingTableComponent(world),
    PlayerPosition: definePlayerPositionComponent(world),
    LocalPlayerPosition: createLocalCache(defineLocalPlayerPositionComponent(world), uniqueWorldId),
    PlayerRelayerChunkPosition: createIndexer(definePlayerRelayerChunkPositionComponent(world)),
    PlayerDirection: definePlayerDirectionComponent(world),
    PlayerLastMessage: definePlayerLastMessage(world),
    PlayerMesh: definePlayerMeshComponent(world),
    UI: defineUIComponent(world),
    FocusedUi: defineFocusedUiComponent(world),
    InventoryIndex: createLocalCache(createIndexer(defineInventoryIndexComponent(world)), uniqueWorldId),
    // Tutorial: createLocalCache(defineTutorialComponent(world), uniqueWorldId),
    // removed cache from tutorial because it triggers on voxel mine, and because of this error: component with id Tutorial was locally cached 260 times since 11:35:35 PM - the local cache is in an alpha state and should not be used with components that update frequently yet
    Tutorial: defineTutorialComponent(world),
    PreTeleportPosition: definePreTeleportPositionComponent(world),
    Sounds: defineSoundComponent(world),
    VoxelSelection: defineVoxelSelectionComponent(world),
    VoxelInterfaceSelection: defineVoxelInterfaceSelectionComponent(world),
    PersistentNotification: definePersistentNotificationComponent(world),
    SpawnCreation: defineSpawnCreationComponent(world),
    SpawnInFocus: defineSpawnInFocusComponent(world),
    SpawnToClassify: defineSpawnToClassifyComponent(world),
    WorldScale: createLocalCache(defineWorldScaleComponent(world)),
  };

  // --- SETUP ----------------------------------------------------------------------
  const { noa, setVoxel, glow } = setupNoaEngine(network);

  const existingWorldScale = getComponentValue(components.WorldScale, SingletonID);
  const worldScale = existingWorldScale?.value.toString() ?? "2";
  noa.worldName = worldScale;

  // Because NOA and RECS currently use different ECS libraries we need to maintain a mapping of RECS ID to Noa ID
  // A future version of OPCraft will remove the NOA ECS library and use pure RECS only
  const mudToNoaId = new Map<Entity, number>();

  // Set initial values
  setComponent(components.UI, SingletonEntity, {
    showAdminPanel: false,
    showCrafting: false,
    showPlugins: false,
  });
  setComponent(components.SelectedSlot, SingletonEntity, { value: 0 });
  !getComponentValue(components.Tutorial, SingletonEntity) &&
    setComponent(components.Tutorial, SingletonEntity, {
      community: true,
      mine: true,
      craft: true,
      build: true,
      inventory: true,
      claim: true,
      moving: true,
      teleport: true,
    });

  // --- API ------------------------------------------------------------------------
  function setCraftingTable(entities: Entity[][]) {
    setComponent(components.CraftingTable, SingletonEntity, {
      value: entities.flat().slice(0, 9),
    });
  }

  // Get a 2d representation of the current crafting table
  // -1 corresponds to empty slots
  function getCraftingTable(): Entity[][] {
    const flatCraftingTable = (getComponentValue(components.CraftingTable, SingletonEntity)?.value || [
      ...EMPTY_CRAFTING_TABLE,
    ]) as Entity[];

    const craftingTable: Entity[][] = [];
    for (let i = 0; i < CRAFTING_SIDE; i++) {
      craftingTable.push([]);
      for (let j = 0; j < CRAFTING_SIDE; j++) {
        craftingTable[i].push(flatCraftingTable[i * CRAFTING_SIDE + j]);
      }
    }

    return craftingTable;
  }

  // Set 2d representation of crafting table
  function setCraftingTableIndex(index: [number, number], entity: Entity | undefined) {
    const craftingTable = getCraftingTable();
    craftingTable[index[0]][index[1]] = entity ?? ("-1" as Entity);
    setCraftingTable(craftingTable);
  }

  function clearCraftingTable() {
    removeComponent(components.CraftingTable, SingletonEntity);
  }

  // Get a trimmed 2d representation of the crafting table
  function getTrimmedCraftingTable() {
    const craftingTable = getCraftingTable();
    // Trim the crafting table array
    let minX = -1;
    let maxX = -1;
    let minY = -1;
    let maxY = -1;

    for (let x = 0; x < CRAFTING_SIDE; x++) {
      for (let y = 0; y < CRAFTING_SIDE; y++) {
        if (getEntityString(getEntitySymbol(craftingTable[x][y])) !== "-1") {
          if (minX === -1) minX = x;
          if (minY === -1) minY = y;
          maxX = x;
          maxY = y;
        }
      }
    }

    if ([minX, minY, maxX, maxY].includes(-1)) return { voxels: [] as Entity[][], voxelTypes: [] as Entity[][] };

    const trimmedCraftingTableVoxels: Entity[][] = [];
    const trimmedCraftingTableVoxelTypes: Entity[][] = [];
    for (let x = 0; x <= maxX - minX; x++) {
      trimmedCraftingTableVoxels.push([]);
      trimmedCraftingTableVoxelTypes.push([]);
      for (let y = 0; y <= maxY - minY; y++) {
        const rawVoxelId = craftingTable[x + minX][y + minY];
        const voxel = ((getEntityString(getEntitySymbol(rawVoxelId)) !== "-1" && rawVoxelId) || "0x00") as Entity;
        const voxelType = ((getEntityString(getEntitySymbol(rawVoxelId)) !== "-1" &&
          getComponentValue(VoxelType, rawVoxelId)?.value) || // TODO: fix this bug. we don't care since crafting isn't implemented rn
          "0x00") as Entity;
        trimmedCraftingTableVoxels[x].push(voxel);
        trimmedCraftingTableVoxelTypes[x].push(voxelType);
      }
    }

    return {
      voxels: trimmedCraftingTableVoxels,
      voxelTypes: trimmedCraftingTableVoxelTypes,
    };
  }

  // Get the voxel type the current crafting table ingredients hash to
  function getCraftingResult(): Entity | undefined {
    const { voxelTypes } = getTrimmedCraftingTable();

    // ABI encode and hash current trimmed crafting table
    const hash = keccak256(abi.encode(["uint256[][]"], [voxelTypes]));

    // Check for voxel types with this recipe hash
    // const resultID = [...getEntitiesWithValue(Recipe, { value: hash })][0];
    const resultID = undefined;
    // const resultID = resultIndex == null ? undefined : world.entities[resultIndex];
    return resultID;
  }

  function teleport(coord: VoxelCoord) {
    setNoaPosition(noa, noa.playerEntity, coord);
  }

  function teleportRandom() {
    const coord = {
      x: random(10000, -10000),
      y: 150,
      z: random(10000, -10000),
    };
    teleport(coord);
  }

  function togglePlugins(open?: boolean) {
    open = open ?? !getComponentValue(components.UI, SingletonEntity)?.showPlugins;
    noa.container.setPointerLock(!open);
    updateComponent(components.UI, SingletonEntity, {
      showCrafting: false,
      showPlugins: open,
    });
  }

  function getVoxelTypeInSelectedSlot(): VoxelBaseTypeId | undefined {
    const selectedSlot = getComponentValue(components.SelectedSlot, SingletonEntity)?.value;
    if (selectedSlot === null) return;
    const voxelBaseTypeId = [
      ...getEntitiesWithValue(components.InventoryIndex, {
        value: selectedSlot,
      }),
    ][0];
    return voxelBaseTypeId;
  }

  function getCurrentPlayerPosition() {
    return getNoaPositionStrict(noa, noa.playerEntity);
  }

  function getCurrentChunk() {
    const position = getCurrentPlayerPosition();
    return getChunkCoord(position);
  }

  function getStakeAndClaim(chunk: Coord) {
    // const chunkEntityIndex = world.entityToIndex.get(getChunkEntity(chunk));
    // const claim = chunkEntityIndex == null ? undefined : getComponentValue(Claim, chunkEntityIndex);
    // const claim = getComponentValue(Claim, getChunkEntity(chunk) as Entity);
    // const stakeEntityIndex = world.entityToIndex.get(getStakeEntity(chunk, connectedAddress.get() || "0x00"));
    // const stake = stakeEntityIndex == null ? undefined : getComponentValue(Stake, getStakeEntity(chunk, connectedAddress.get() || "0x00"));
    // const stake = getComponentValue(Stake, getStakeEntity(chunk, connectedAddress.get() || "0x00"));
    // const stake = getComponentValue(Stake, "0x00" as Entity);
    // return { claim, stake };
    return undefined;
  }

  function playNextTheme() {
    const sounds = getComponentValue(components.Sounds, SingletonEntity);
    if (!sounds?.themes || !isNotEmpty(sounds.themes)) return;
    const prevThemeIndex = sounds.playingTheme ? sounds.themes.findIndex((e) => e === sounds.playingTheme) : -1;
    const nextThemeIndex = (prevThemeIndex + 1) % sounds.themes.length;
    const playingTheme = sounds.themes[nextThemeIndex];
    updateComponent(components.Sounds, SingletonEntity, { playingTheme });
  }

  function playRandomTheme() {
    const sounds = getComponentValue(components.Sounds, SingletonEntity);
    if (!sounds?.themes || !isNotEmpty(sounds.themes)) return;
    const playingTheme = pickRandom(sounds.themes);
    updateComponent(components.Sounds, SingletonEntity, { playingTheme });
  }

  const scene = noa.rendering.getScene();

  const voxelMaterials: Map<string, BABYLON.Material | undefined> = new Map();
  function voxelUVWrapSubscription(voxelVariantTypeId: VoxelVariantTypeId, voxelVariantNoaDef: VoxelVariantNoaDef) {
    if (voxelVariantNoaDef.noaVoxelDef?.uvWrap) {
      // console.log("Registering uvWrap", voxelVariantKey);
      const voxelMaterial = noa.rendering.makeStandardMaterial("voxelMaterial-" + voxelVariantTypeId);
      voxelMaterial.diffuseTexture = new Texture(
        voxelVariantNoaDef.noaVoxelDef.uvWrap,
        scene,
        true,
        true,
        Texture.NEAREST_SAMPLINGMODE
      );
      voxelMaterials.set(voxelVariantTypeId, voxelMaterial);
    } else {
      voxelMaterials.set(voxelVariantTypeId, undefined);
    }
  }

  VoxelVariantSubscriptions.push(voxelUVWrapSubscription);

  // initial run
  for (const [voxelVariantTypeId, voxelVariantNoaDef] of VoxelVariantIdToDef.entries()) {
    voxelUVWrapSubscription(voxelVariantTypeId, voxelVariantNoaDef);
  }

  setComponent(components.FocusedUi, SingletonEntity, { value: FocusedUiType.WORLD as any });

  // --- SETUP NOA COMPONENTS AND MODULES --------------------------------------------------------
  monkeyPatchMeshComponent(noa);
  registerModelComponent(noa);
  registerRotationComponent(noa);
  registerTargetedRotationComponent(noa);
  registerTargetedPositionComponent(noa);
  registerHandComponent(noa, getVoxelTypeInSelectedSlot, getVoxelPreviewVariant, voxelMaterials);
  registerMiningVoxelComponent(noa, network);
  setupClouds(noa);
  setupSky(noa);
  setupHand(noa, network);
  // setupDayNightCycle(noa, glow); // Curtis removed this because he had to constantly change his monitor brightness

  // Pause noa until initial loading is done
  noa.setPaused(true);
  awaitStreamValue(doneSyncing$, (isDoneSyncing) => isDoneSyncing).then(() => noa.setPaused(false));

  // --- SETUP STREAMS --------------------------------------------------------------
  // (Create streams as BehaviorSubject to allow for multiple observers and getting the current value)
  const playerPosition$ = new BehaviorSubject(getCurrentPlayerPosition());
  world.registerDisposer(timer(0, 200).pipe(map(getCurrentPlayerPosition)).subscribe(playerPosition$)?.unsubscribe);

  const slowPlayerPosition$ = playerPosition$.pipe(throttleTime(10000));

  const playerChunk$ = new BehaviorSubject(getCurrentChunk());
  world.registerDisposer(playerPosition$.pipe(map((pos) => getChunkCoord(pos))).subscribe(playerChunk$)?.unsubscribe);

  const zoomEvent$ = new Subject<boolean>(); // When the user presses the sidebar, this stream tells the zoom overlay to trigger. True if we're zooming in, false if we're zooming out.

  // const stakeAndClaim$ = new BehaviorSubject(getStakeAndClaim(getCurrentChunk()));
  // world.registerDisposer(
  //   playerChunk$.pipe(map((coord) => getStakeAndClaim(coord))).subscribe(stakeAndClaim$)?.unsubscribe
  // );

  const context = {
    world,
    components,
    mudToNoaId,
    noa,
    api: {
      setVoxel,
      setCraftingTable,
      getCraftingTable,
      clearCraftingTable,
      setCraftingTableIndex,
      getVoxelTypeInSelectedSlot,
      getTrimmedCraftingTable,
      getCraftingResult,
      teleport,
      teleportRandom,
      togglePlugins,
      getCurrentChunk,
      getCurrentPlayerPosition,
      getStakeAndClaim,
      playRandomTheme,
      playNextTheme,
    },
    streams: {
      playerPosition$,
      slowPlayerPosition$,
      playerChunk$,
      zoomEvent$,
      // stakeAndClaim$,
    },
    SingletonEntity,
    audioEngine: Engine.audioEngine,
  };

  // --- SYSTEMS --------------------------------------------------------------------
  const layers = {
    network,
    noa: context,
  };
  createInputSystem(layers);
  createActivateVoxelSystem(network, context);
  createVoxelVariantSystem(network, context);
  createVoxelSystem(network, context);
  createPlayerPositionSystem(network, context);
  createRelaySystem(network, context);
  createInventoryIndexSystem(network, context);
  createSyncLocalPlayerPositionSystem(network, context);
  // createCreativeModeSystem(network, context);
  createSpawnPlayerSystem(network, context);
  // createTutorialSystem(network, context);
  createSoundSystem(network, context);
  createVoxelSelectionOverlaySystem(network, context);
  createSpawnCreationOverlaySystem(network, context);
  createSpawnOverlaySystem(network, context);

  return context;
}