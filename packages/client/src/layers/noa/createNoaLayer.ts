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
} from "./components";
import { CRAFTING_SIDE, EMPTY_CRAFTING_TABLE } from "./constants";
import { setupHand } from "./engine/hand";
import { monkeyPatchMeshComponent } from "./engine/components/monkeyPatchMeshComponent";
import { registerRotationComponent, registerTargetedRotationComponent } from "./engine/components/rotationComponent";
import { setupClouds, setupSky } from "./engine/sky";
import { setupNoaEngine } from "./setup";
import {
  createBlockSystem,
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
import { registerMiningBlockComponent } from "./engine/components/miningBlockComponent";
import { defineInventoryIndexComponent } from "./components/InventoryIndex";
import { setupDayNightCycle } from "./engine/dayNightCycle";
import { getNoaPositionStrict, setNoaPosition } from "./engine/components/utils";
import { registerTargetedPositionComponent } from "./engine/components/targetedPositionComponent";
import { defaultAbiCoder as abi, keccak256 } from "ethers/lib/utils";
import { SingletonID, SyncState } from "@latticexyz/network";
import { getChunkCoord, getChunkEntity } from "../../utils/chunk";
import { BehaviorSubject, map, throttleTime, timer } from "rxjs";
// import { getStakeEntity } from "../../utils/stake"; // commented cause we aren't using it
import { createCreativeModeSystem } from "./systems/createCreativeModeSystem";
import { createSpawnPlayerSystem } from "./systems/createSpawnPlayerSystem";
import { definePlayerMeshComponent } from "./components/PlayerMesh";
import { Engine } from "@babylonjs/core";
import { to64CharAddress } from "../../utils/entity";

export function createNoaLayer(network: NetworkLayer) {
  const world = namespaceWorld(network.world, "noa");
  const {
    worldAddress,
    network: {
      config: { chainId },
      connectedAddress,
    },
    components: { OwnedBy, Item, Recipe, Claim, Stake, LoadingState },
    api: { build },
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
    InventoryIndex: createLocalCache(createIndexer(defineInventoryIndexComponent(world)), uniqueWorldId),
    Tutorial: createLocalCache(defineTutorialComponent(world), uniqueWorldId),
    PreTeleportPosition: definePreTeleportPositionComponent(world),
    Sounds: defineSoundComponent(world),
  };

  // --- SETUP ----------------------------------------------------------------------
  const { noa, setBlock, glow } = setupNoaEngine(network.api);

  // Because NOA and RECS currently use different ECS libraries we need to maintain a mapping of RECS ID to Noa ID
  // A future version of OPCraft will remove the NOA ECS library and use pure RECS only
  const mudToNoaId = new Map<Entity, number>();

  // Set initial values
  setComponent(components.UI, SingletonEntity, {
    showComponentBrowser: false,
    showInventory: false,
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

  // TODO: reenable when we add selecting voxels
  // setComponent(components.VoxelSelection, SingletonEntity, { points: [] });

  // --- API ------------------------------------------------------------------------
  function setCraftingTable(entities: Entity[][]) {
    setComponent(components.CraftingTable, SingletonEntity, { value: entities.flat().slice(0, 9) });
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
        if (getEntityString(getEntitySymbol(craftingTable[x][y])) !== "-1"){
          if (minX === -1) minX = x;
          if (minY === -1) minY = y;
          maxX = x;
          maxY = y;
        }
      }
    }

    if ([minX, minY, maxX, maxY].includes(-1)) return { items: [] as Entity[][], types: [] as Entity[][] };

    const trimmedCraftingTableItems: Entity[][] = [];
    const trimmedCraftingTableTypes: Entity[][] = [];
    for (let x = 0; x <= maxX - minX; x++) {
      trimmedCraftingTableItems.push([]);
      trimmedCraftingTableTypes.push([]);
      for (let y = 0; y <= maxY - minY; y++) {
        const blockEntity = craftingTable[x + minX][y + minY];
        const blockID = ((getEntityString(getEntitySymbol(blockEntity)) !== "-1" && blockEntity) || "0x00") as Entity;
        const blockType = ((getEntityString(getEntitySymbol(blockEntity)) !== "-1" && getComponentValue(Item, blockEntity)?.value) || "0x00") as Entity;
        trimmedCraftingTableItems[x].push(blockID);
        trimmedCraftingTableTypes[x].push(blockType);
      }
    }

    return { items: trimmedCraftingTableItems, types: trimmedCraftingTableTypes };
  }

  // Get the block type the current crafting table ingredients hash to
  function getCraftingResult(): Entity | undefined {
    const { types } = getTrimmedCraftingTable();

    // ABI encode and hash current trimmed crafting table
    const hash = keccak256(abi.encode(["uint256[][]"], [types]));

    // Check for block types with this recipe hash
    const resultID = [...getEntitiesWithValue(Recipe, { value: hash })][0];
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
      showInventory: false,
      showCrafting: false,
      showPlugins: open,
    });
  }

  function toggleInventory(open?: boolean, crafting?: boolean) {
    open = open ?? !getComponentValue(components.UI, SingletonEntity)?.showInventory;
    noa.container.setPointerLock(!open);
    updateComponent(components.UI, SingletonEntity, {
      showPlugins: false,
      showInventory: open,
      showCrafting: Boolean(open && crafting),
    });
  }

  function getSelectedBlockType(): Entity | undefined {
    const selectedSlot = getComponentValue(components.SelectedSlot, SingletonEntity)?.value;
    if (selectedSlot == null) return;
    const blockID = [...getEntitiesWithValue(components.InventoryIndex, { value: selectedSlot })][0];
    // const blockID = blockIndex != null && world.entities[blockIndex];
    if (!blockID) return;
    return blockID;
  }

  function placeSelectedItem(coord: VoxelCoord) {
    const blockID = getSelectedBlockType();
    if (!blockID) return console.warn("No item at selected slot");
    const ownedEntityOfSelectedType = [
      ...runQuery([HasValue(OwnedBy, { value: to64CharAddress(connectedAddress.get()) }), HasValue(Item, { value: blockID })]),
    ][0];
    if (ownedEntityOfSelectedType == null) return console.warn("No owned item of type", blockID);
    // const itemEntity = world.entities[ownedEntityOfSelectedType];
    const itemEntity = ownedEntityOfSelectedType;
    network.api.build(itemEntity, coord);
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
    const claim = getComponentValue(Claim, getChunkEntity(chunk) as Entity);
    // const stakeEntityIndex = world.entityToIndex.get(getStakeEntity(chunk, connectedAddress.get() || "0x00"));
    // const stake = stakeEntityIndex == null ? undefined : getComponentValue(Stake, getStakeEntity(chunk, connectedAddress.get() || "0x00"));
    // const stake = getComponentValue(Stake, getStakeEntity(chunk, connectedAddress.get() || "0x00"));
    const stake = getComponentValue(Stake, "0x00" as Entity);
    return { claim, stake };
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

  // --- SETUP NOA COMPONENTS AND MODULES --------------------------------------------------------
  monkeyPatchMeshComponent(noa);
  registerModelComponent(noa);
  registerRotationComponent(noa);
  registerTargetedRotationComponent(noa);
  registerTargetedPositionComponent(noa);
  registerHandComponent(noa, getSelectedBlockType);
  registerMiningBlockComponent(noa, network);
  setupClouds(noa);
  setupSky(noa);
  setupHand(noa);
  setupDayNightCycle(noa, glow);

  // Pause noa until initial loading is done
  setTimeout(() => {
    if (getComponentValue(LoadingState, SingletonEntity)?.state !== SyncState.LIVE) noa.setPaused(true);
  }, 1000);
  awaitStreamValue(LoadingState.update$, ({ value }) => value[0]?.state === SyncState.LIVE).then(() =>
    noa.setPaused(false)
  );

  // --- SETUP STREAMS --------------------------------------------------------------
  // (Create streams as BehaviorSubject to allow for multiple observers and getting the current value)
  const playerPosition$ = new BehaviorSubject(getCurrentPlayerPosition());
  world.registerDisposer(timer(0, 200).pipe(map(getCurrentPlayerPosition)).subscribe(playerPosition$)?.unsubscribe);

  const slowPlayerPosition$ = playerPosition$.pipe(throttleTime(10000));

  const playerChunk$ = new BehaviorSubject(getCurrentChunk());
  world.registerDisposer(playerPosition$.pipe(map((pos) => getChunkCoord(pos))).subscribe(playerChunk$)?.unsubscribe);

  const stakeAndClaim$ = new BehaviorSubject(getStakeAndClaim(getCurrentChunk()));
  world.registerDisposer(
    playerChunk$.pipe(map((coord) => getStakeAndClaim(coord))).subscribe(stakeAndClaim$)?.unsubscribe
  );

  const context = {
    world,
    components,
    mudToNoaId,
    noa,
    api: {
      setBlock,
      setCraftingTable,
      getCraftingTable,
      clearCraftingTable,
      setCraftingTableIndex,
      getSelectedBlockType,
      getTrimmedCraftingTable,
      getCraftingResult,
      teleport,
      teleportRandom,
      toggleInventory,
      togglePlugins,
      placeSelectedItem,
      getCurrentChunk,
      getCurrentPlayerPosition,
      getStakeAndClaim,
      playRandomTheme,
      playNextTheme,
    },
    streams: { playerPosition$, slowPlayerPosition$, playerChunk$, stakeAndClaim$ },
    SingletonEntity,
    audioEngine: Engine.audioEngine,
  };

  // --- SYSTEMS --------------------------------------------------------------------
  createInputSystem(network, context);
  createBlockSystem(network, context);
  createPlayerPositionSystem(network, context);
  createRelaySystem(network, context);
  createInventoryIndexSystem(network, context);
  createSyncLocalPlayerPositionSystem(network, context);
  // createCreativeModeSystem(network, context);
  createSpawnPlayerSystem(network, context);
  createTutorialSystem(network, context);
  createSoundSystem(network, context);

  return context;
}
