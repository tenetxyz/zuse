import { getComponentValue, HasValue, runQuery, setComponent, updateComponent } from "@latticexyz/recs";
import { sleep, VoxelCoord, keccak256 } from "@latticexyz/utils";
import { FAST_MINING_DURATION } from "../constants";
import { HandComponent, HAND_COMPONENT } from "../engine/components/handComponent";
import { MiningVoxelComponent, MINING_VOXEL_COMPONENT } from "../engine/components/miningVoxelComponent";
import { getNoaComponent, getNoaComponentStrict } from "../engine/components/utils";
import { toast } from "react-toastify";
import { calculateMinMax, getTargetedSpawnId, getTargetedVoxelCoord, TargetedBlock } from "../../../utils/voxels";
import { NotificationIcon } from "../components/persistentNotification";
import { BEDROCK_ID, getBedrockHeight, TILE_Y } from "../../network/api/terrain/occurrence";
import { DEFAULT_BLOCK_TEST_DISTANCE } from "../setup/setupNoaEngine";
import { calculateCornersFromTargetedBlock } from "./createSpawnCreationOverlaySystem";
import { FocusedUiType } from "../components/FocusedUi";
import { Layers } from "../../../types";
import { calculateParentCoord, getWorldScale, voxelCoordToString } from "../../../utils/coord";
import { renderFloatingTextAboveCoord } from "./renderFloatingText";
import { InterfaceVoxel, VoxelEntity } from "../types";
import { World } from "noa-engine/dist/src/lib/world";
import {
  disableInputs,
  enableInputs,
  bindInputEvent as bindInputEventUsingNoa,
  unbindInputEvent as unbindInputEventUsingNoa,
} from "./createInputSystemHelpers";
import { Creation } from "@/mud/componentParsers/creation";

// https://fenomas.github.io/noa/API/classes/_internal_.Inputs.html#bind
// Key strings should align to KeyboardEvent.code strings - e.g. KeyA, ArrowDown, etc.
// https://developer.mozilla.org/en-US/docs/Web/API/UI_Events/Keyboard_event_code_values
export const InputEvent = {
  "cancel-action": ["Backspace", "Delete"],
  "toggle-inventory": "KeyE",
  sidebar: ["Minus", "KeyQ"],
  "select-voxel": "KeyV",
  fire: ["Mouse1", "KeyF"],
  "alt-fire": ["Mouse3", "KeyR"], // Note: if you ever change the name of this event, you might break some logic since in the code below, we first unbind alt-fire to remove the original binding of "E"
  jump: "Space",
  moving: ["KeyW", "KeyA", "KeyS", "KeyD", "ArrowUp", "ArrowLeft", "ArrowDown", "ArrowRight"],
  "voxel-explorer": "KeyB",
  slot: ["Digit1", "Digit2", "Digit3", "Digit4", "Digit5", "Digit6", "Digit7", "Digit8", "Digit9"],
  plugins: "Semicolon",
  spawn: "KeyO",
  preteleport: "KeyP",
  "spawn-creation": "Enter",
  crouch: "ShiftLeft",
};

export type InputEventKey = keyof typeof InputEvent;

export function closeSidebar(FocusedUi, SingletonEntity) {
  setComponent(FocusedUi, SingletonEntity, { value: FocusedUiType.WORLD });
}

export function openSidebar(FocusedUi, SingletonEntity, PersistentNotification, SpawnCreation, noa) {
  // clear persistent notification when we open the inventory
  setComponent(PersistentNotification, SingletonEntity, {
    message: "",
    icon: NotificationIcon.NONE,
  });

  // clear SpawnCreation when we open the inventory
  setComponent(SpawnCreation, SingletonEntity, {
    creation: undefined,
  });
  noa.blockTestDistance = DEFAULT_BLOCK_TEST_DISTANCE; // reset block test distance

  setComponent(FocusedUi, SingletonEntity, { value: FocusedUiType.TENET_SIDEBAR });
}

export function createInputSystem(layers: Layers) {
  const {
    noa: {
      noa,
      components: {
        SelectedSlot,
        FocusedUi,
        Tutorial,
        PreTeleportPosition,
        VoxelSelection,
        SpawnCreation,
        PersistentNotification,
        VoxelInterfaceSelection,
        SpawnToClassify,
      },
      SingletonEntity,
      api: { togglePlugins, getVoxelTypeInSelectedSlot, teleport },
      streams: { playerPosition$ },
    },
    network: {
      parsedComponents: { ParsedCreationRegistry },
      registryComponents: { VoxelTypeRegistry },
      network: {
        connectedAddress,
        config: { blockExplorer },
      },
      streams: { balanceGwei$ },
      api: { spawnCreation, build, activate, getEntityAtPosition },
    },
  } = layers;

  const bindInputEvent = (key: InputEventKey) => {
    bindInputEventUsingNoa(noa, key);
  };

  const unbindInputEvent = (key: InputEventKey) => {
    unbindInputEventUsingNoa(noa, key);
  };

  const onDownInputEvent = (key: InputEventKey, handler: (e?: any) => void) => {
    noa.inputs.down.on(key, handler);
  };

  const onUpInputEvent = (key: InputEventKey, handler: (e?: any) => void) => {
    noa.inputs.up.on(key, handler);
  };

  // If the user is in a UI (e.g. inventory), disable inputs that could conflict with typing into the UI
  // otherwise, enable the inputs
  FocusedUi.update$.subscribe((update) => {
    const focusedUiType = update.value[0]?.value ?? FocusedUiType.WORLD; // Assume the user is focuesed on the world if focusedUiType is undefined
    if (focusedUiType === FocusedUiType.WORLD) {
      enableInputs(noa);
      noa.container.setPointerLock(true);
    } else {
      noa.container.setPointerLock(false);
      disableInputs(noa, focusedUiType as FocusedUiType);
    }
  });

  // mine targeted voxel on left click
  bindInputEvent("fire");

  function canInteract() {
    if (balanceGwei$.getValue() === 0) return false;
    // const { claim } = stakeAndClaim$.getValue() || {};
    const claim = undefined;
    const playerAddress = connectedAddress.get();
    if (!playerAddress) return false;
    if (!claim) return true;
    return true;
    // return claim.claimer === formatEntityID(playerAddress);
  }

  function mineTargetedVoxel() {
    if (noa.targetedBlock) {
      if (!canInteract()) return;
      const pos = noa.targetedBlock.position;
      if (pos[1] < getBedrockHeight(getWorldScale(noa))) return;
      const miningComponent = getNoaComponentStrict<MiningVoxelComponent>(
        noa,
        noa.playerEntity,
        MINING_VOXEL_COMPONENT
      );
      // const creativeMode = getComponentValue(GameConfig, SingletonEntity)?.creativeMode;
      const creativeMode = false;
      const handComponent = getNoaComponentStrict<HandComponent>(noa, noa.playerEntity, HAND_COMPONENT);
      if (miningComponent.active) {
        return;
      }
      miningComponent.active = true;
      handComponent.isMining;
      miningComponent.coord = { x: pos[0], y: pos[1], z: pos[2] };

      if (creativeMode) {
        miningComponent.duration = 10;
      } else if (getVoxelTypeInSelectedSlot()?.voxelTypeId === BEDROCK_ID) {
        miningComponent.duration = FAST_MINING_DURATION;
      }
      return miningComponent;
    }
  }

  let firePressed = false;
  onDownInputEvent("fire", async () => {
    if (!noa.container.hasPointerLock) return;
    if (isSelectingVoxel) {
      selectCorner(true);
      return;
    }

    firePressed = true;
    const miningComponent = mineTargetedVoxel();
    while (firePressed) {
      if (!miningComponent?.duration) return;
      await sleep(miningComponent.duration + 100);
      if (firePressed) mineTargetedVoxel();
    }
  });

  const selectCorner = (isCorner1: boolean) => {
    if (!noa.targetedBlock) {
      return;
    }
    hasSelectedCorner = true;

    const coord = getTargetedVoxelCoord(noa);
    const voxelSelection = getComponentValue(VoxelSelection, SingletonEntity);
    const corner1 = isCorner1 ? coord : voxelSelection?.corner1;
    const corner2 = !isCorner1 ? coord : voxelSelection?.corner2;

    setComponent(VoxelSelection, SingletonEntity, {
      corner1: corner1,
      corner2: corner2,
    } as any);
  };

  onUpInputEvent("fire", () => {
    if (!noa.container.hasPointerLock) return;

    firePressed = false;
    const miningComponent = getNoaComponentStrict<MiningVoxelComponent>(noa, noa.playerEntity, MINING_VOXEL_COMPONENT);
    const handComponent = getNoaComponentStrict<HandComponent>(noa, noa.playerEntity, HAND_COMPONENT);
    miningComponent.active = false;
    handComponent.isMining = false;
  });

  noa.on("targetBlockChanged", (targetedBlock: { position: number[] }) => {
    if (!noa.container.hasPointerLock) return;

    const miningComponent = getNoaComponent<MiningVoxelComponent>(noa, noa.playerEntity, MINING_VOXEL_COMPONENT);
    if (!miningComponent) return;
    const handComponent = getNoaComponentStrict<HandComponent>(noa, noa.playerEntity, HAND_COMPONENT);
    if (!targetedBlock) {
      return;
    }
    const {
      position: [x, y, z],
    } = targetedBlock;
    if (miningComponent.coord.x !== x || miningComponent.coord.y !== y || miningComponent.coord.z !== z) {
      miningComponent.active = false;
      handComponent.isMining = false;
    }
  });

  // place a voxel on right click
  unbindInputEvent("alt-fire"); // Unbind to remove the default binding of "E"
  bindInputEvent("alt-fire");

  onDownInputEvent("alt-fire", () => {
    if (!canInteract()) return;
    if (!noa.container.hasPointerLock) return;
    if (isSelectingVoxel) {
      selectCorner(false);
      return;
    }

    if (!noa.targetedBlock) {
      // there are no blocks in sight. so do nothing!
      return;
    }

    const voxelBaseTypeId = getVoxelTypeInSelectedSlot();
    if (voxelBaseTypeId) {
      // you are holding a block and are looking at a block. so place the block at the adjacent coord
      const pos = noa.targetedBlock.adjacent;
      const coord = { x: pos[0], y: pos[1], z: pos[2] };
      build(noa, voxelBaseTypeId, coord);
    } else {
      // you are holding nothing and are looking at a block. So activate the block
      const entity = getEntityAtPosition(getTargetedVoxelCoord(noa), getWorldScale(noa));
      if (entity) {
        activate(entity);
      }
    }

    // Open crafting UI if the targeted voxel is a crafting table
    // TODO: Add back when we add crafting
    // if (
    //   runQuery([
    //     HasValue(Position, {
    //       x: targeted[0],
    //       y: targeted[1],
    //       z: targeted[2],
    //     }),
    //     HasValue(VoxelType, { value: VoxelTypeKeyToId.Crafting }),
    //   ]).size > 0
    // ) {
    //   return toggleInventory(true, true);
    // }
  });

  // Control selected slot with keys 1-9
  bindInputEvent("slot");

  // Reset moving tutorial with W, A, S, D
  bindInputEvent("moving");
  onDownInputEvent("moving", () => {
    if (!noa.container.hasPointerLock) return;
    updateComponent(Tutorial, SingletonEntity, { moving: false });
  });

  onDownInputEvent("slot", (e) => {
    if (!noa.container.hasPointerLock) return;
    const key = Number(e.key) - 1;
    setComponent(SelectedSlot, SingletonEntity, { value: key });
  });

  bindInputEvent("sidebar");
  onDownInputEvent("sidebar", () => {
    const isSidebarOpen = getComponentValue(FocusedUi, SingletonEntity)?.value === FocusedUiType.TENET_SIDEBAR;
    if (isSidebarOpen) {
      closeSidebar(FocusedUi, SingletonEntity);
    } else {
      openSidebar(FocusedUi, SingletonEntity, PersistentNotification, SpawnCreation, noa);
    }
  });

  bindInputEvent("toggle-inventory");
  onDownInputEvent("toggle-inventory", () => {
    if (!canInteract()) return;
    const isInventoryOpen = getComponentValue(FocusedUi, SingletonEntity)?.value === FocusedUiType.INVENTORY;
    if (isInventoryOpen) {
      closeInventory();
    } else {
      openInventory();
    }
    updateComponent(Tutorial, SingletonEntity, { inventory: false });
  });

  function closeInventory() {
    setComponent(FocusedUi, SingletonEntity, { value: FocusedUiType.WORLD });
  }

  function openInventory() {
    // clear persistent notification when we open the inventory
    setComponent(PersistentNotification, SingletonEntity, {
      message: "",
      icon: NotificationIcon.NONE,
    });

    // clear SpawnCreation when we open the inventory
    setComponent(SpawnCreation, SingletonEntity, {
      creation: undefined,
    });
    noa.blockTestDistance = DEFAULT_BLOCK_TEST_DISTANCE; // reset block test distance

    setComponent(FocusedUi, SingletonEntity, { value: FocusedUiType.INVENTORY });
  }

  // bindInputEvent("stake", "X");
  // onDownInputEvent("stake", () => {
  //   if (!noa.container.hasPointerLock) return;
  //   const chunk = getCurrentChunk();
  //   chunk && stake(chunk);
  // });

  // bindInputEvent("claim", "C");
  // onDownInputEvent("claim", () => {
  //   if (!noa.container.hasPointerLock) return;
  //   const chunk = getCurrentChunk();
  //   chunk && claim(chunk);
  // });

  bindInputEvent("voxel-explorer");
  onDownInputEvent("voxel-explorer", () => {
    if (!noa.container.hasPointerLock) return;
    window.open(blockExplorer);
  });

  bindInputEvent("spawn");
  onDownInputEvent("spawn", () => {
    if (!noa.container.hasPointerLock) return;
    setComponent(PreTeleportPosition, SingletonEntity, playerPosition$.getValue());
    const spawn_point = calculateParentCoord({ x: 0, y: TILE_Y + 1, z: 0 }, getWorldScale(noa));
    teleport(spawn_point);
    updateComponent(Tutorial, SingletonEntity, { teleport: false });
  });

  bindInputEvent("preteleport");
  onDownInputEvent("preteleport", () => {
    if (!noa.container.hasPointerLock) return;
    const preTeleportPosition = getComponentValue(PreTeleportPosition, SingletonEntity);
    if (!preTeleportPosition) return;
    teleport(preTeleportPosition);
    updateComponent(Tutorial, SingletonEntity, { teleport: false });
  });

  bindInputEvent("plugins");
  onDownInputEvent("plugins", () => {
    togglePlugins();
  });

  let hasSelectedCorner = false;
  let isSelectingVoxel = false;
  bindInputEvent("select-voxel");
  onDownInputEvent("select-voxel", () => {
    isSelectingVoxel = true;
    hasSelectedCorner = false;
  });
  onUpInputEvent("select-voxel", () => {
    isSelectingVoxel = false;
    if (!canInteract()) return;
    if (hasSelectedCorner) {
      // the user selected a corner while they were pressing "v". This means that
      // we should not select a voxel
      hasSelectedCorner = false;
      return;
    }

    if (!noa.targetedBlock) {
      return;
    }
    const spawnToClassify = getComponentValue(SpawnToClassify, SingletonEntity);
    const voxelSelection = getComponentValue(VoxelInterfaceSelection, SingletonEntity);
    if (!spawnToClassify || !spawnToClassify.spawn || !voxelSelection) {
      return;
    }

    const spawnId = getTargetedSpawnId(layers, noa.targetedBlock as any);
    const isVoxelPartOfSpawn = spawnId !== undefined;
    if (isVoxelPartOfSpawn) {
      const voxelSelection = getComponentValue(VoxelInterfaceSelection, SingletonEntity);
      if (!voxelSelection || !voxelSelection.interfaceVoxels) return;
      const coord = getTargetedVoxelCoord(noa);
      const entityAtCoord = getEntityAtPosition(coord, getWorldScale(noa));

      if (!entityAtCoord) {
        return;
      }
      const entityParts = entityAtCoord.split(":");
      const interfaceVoxel: VoxelEntity = {
        scale: parseInt(entityParts[0]),
        entityId: entityParts[1],
      };

      // Note: We need to clone here because it won't let me modify the entity directly
      const newInterfaceVoxels = structuredClone(voxelSelection.interfaceVoxels);
      const newInterfaceVoxel: InterfaceVoxel = newInterfaceVoxels[voxelSelection.selectingVoxelIdx];
      newInterfaceVoxel.entity = interfaceVoxel;
      setComponent(VoxelInterfaceSelection, SingletonEntity, {
        interfaceVoxels: newInterfaceVoxels,
        selectingVoxelIdx: voxelSelection.selectingVoxelIdx,
      });
      toast(`Selected voxel at ${voxelCoordToString(coord)}`);
    } else {
      toast(`You can only select a voxel that is part of a spawn.`);
    }
  });

  bindInputEvent("cancel-action");
  onDownInputEvent("cancel-action", () => {
    // clear the spawn creation component so the outline disappears
    setComponent(SpawnCreation, SingletonEntity, { creation: undefined });
    noa.blockTestDistance = DEFAULT_BLOCK_TEST_DISTANCE;

    // clear the persistent notification
    setComponent(PersistentNotification, SingletonEntity, {
      message: "",
      icon: NotificationIcon.NONE,
    });

    // clear your selected voxels
    setComponent(VoxelSelection, SingletonEntity, {
      corner1: undefined,
      corner2: undefined,
    });
  });

  bindInputEvent("spawn-creation");
  onDownInputEvent("spawn-creation", () => {
    if (!noa.container.hasPointerLock) {
      return;
    }
    const creation: Creation | undefined = getComponentValue(SpawnCreation, SingletonEntity)?.creation;
    if (creation === undefined) {
      return;
    }
    // @ts-nocheck
    const { corner1, corner2 } = calculateCornersFromTargetedBlock(
      noa,
      VoxelTypeRegistry,
      ParsedCreationRegistry,
      creation
    );
    const { minX, minY, minZ } = calculateMinMax(corner1, corner2);

    spawnCreation({ x: minX, y: minY, z: minZ }, (creation as Creation).creationId);
  });

  bindInputEvent("crouch");

  // We are not doing anything when crouching in this file because noa's movement
  // component reads the crouch event and uses it to descend when flying
  // onDownInputEvent("crouch", () => {});
}
