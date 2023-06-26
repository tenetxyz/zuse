import { getComponentValue, HasValue, runQuery, setComponent, updateComponent } from "@latticexyz/recs";
import { sleep, VoxelCoord, keccak256 } from "@latticexyz/utils";
import { NetworkLayer } from "../../network";
import { FAST_MINING_DURATION, SPAWN_POINT } from "../constants";
import { HandComponent, HAND_COMPONENT } from "../engine/components/handComponent";
import { MiningVoxelComponent, MINING_VOXEL_COMPONENT } from "../engine/components/miningVoxelComponent";
import { getNoaComponent, getNoaComponentStrict } from "../engine/components/utils";
import { NoaLayer } from "../types";
import { toast } from "react-toastify";
import { Creation } from "../../react/components/CreationStore";
import { getCoordOfVoxelOnFaceYouTargeted, getTargetedVoxelCoord } from "../../../utils/voxels";
import { NotificationIcon } from "../components/persistentNotification";
import { BEDROCK_ID } from "../../network/api/terrain/occurrence";

export function createInputSystem(network: NetworkLayer, noaLayer: NoaLayer) {
  const {
    noa,
    components: {
      SelectedSlot,
      UI,
      Tutorial,
      PreTeleportPosition,
      VoxelSelection,
      SpawnCreation,
      PersistentNotification,
    },
    SingletonEntity,
    api: { toggleInventory, togglePlugins, placeSelectedVoxelType, getVoxelTypeInSelectedSlot, teleport },
    streams: { stakeAndClaim$, playerPosition$ },
  } = noaLayer;

  const {
    contractComponents: { VoxelType, Position },
    // api: { stake, claim },
    network: { connectedAddress },
    streams: { balanceGwei$ },
    api: { spawnCreation },
  } = network;

  // mine targeted voxel on left click
  noa.inputs.bind("fire", "F");

  function canInteract() {
    if (balanceGwei$.getValue() === 0) return false;
    const { claim } = stakeAndClaim$.getValue() || {};
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
      if (pos[1] < -63) return;
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
  noa.inputs.down.on("fire", async function () {
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
      points: voxelSelection?.points,
      corner1: corner1,
      corner2: corner2,
    } as any);
  };

  noa.inputs.up.on("fire", function () {
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
  noa.inputs.unbind("alt-fire"); // Unbind to remove the default binding of "E"
  noa.inputs.bind("alt-fire", "<mouse 3>", "R");

  noa.inputs.down.on("alt-fire", function () {
    if (!canInteract()) return;
    if (!noa.container.hasPointerLock) return;
    if (isSelectingVoxel) {
      selectCorner(false);
      return;
    }

    if (noa.targetedBlock) {
      const pos = noa.targetedBlock.adjacent;
      const targeted = noa.targetedBlock.position;

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
      placeSelectedVoxelType({ x: pos[0], y: pos[1], z: pos[2] });
    }
  });

  // Control selected slot with keys 1-9
  noa.inputs.bind("slot", "1", "2", "3", "4", "5", "6", "7", "8", "9");

  // Reset moving tutorial with W, A, S, D
  noa.inputs.bind("moving", "W", "A", "S", "D");
  noa.inputs.down.on("moving", () => {
    if (!noa.container.hasPointerLock) return;
    updateComponent(Tutorial, SingletonEntity, { moving: false });
  });

  noa.inputs.down.on("slot", (e) => {
    if (!noa.container.hasPointerLock) return;
    const key = Number(e.key) - 1;
    setComponent(SelectedSlot, SingletonEntity, { value: key });
  });

  noa.inputs.bind("admin-panel", "-");
  noa.inputs.down.on("admin-panel", () => {
    const showAdminPanel = getComponentValue(UI, SingletonEntity)?.showAdminPanel;
    updateComponent(UI, SingletonEntity, {
      showAdminPanel: !showAdminPanel,
    });
  });

  noa.inputs.bind("inventory", "E");
  noa.inputs.down.on("inventory", () => {
    if (!canInteract()) return;
    const showInventory = getComponentValue(UI, SingletonEntity)?.showInventory;
    if (!noa.container.hasPointerLock && !showInventory) {
      return;
    }

    toggleInventory();
    updateComponent(Tutorial, SingletonEntity, { inventory: false });
  });

  // noa.inputs.bind("stake", "X");
  // noa.inputs.down.on("stake", () => {
  //   if (!noa.container.hasPointerLock) return;
  //   const chunk = getCurrentChunk();
  //   chunk && stake(chunk);
  // });

  // noa.inputs.bind("claim", "C");
  // noa.inputs.down.on("claim", () => {
  //   if (!noa.container.hasPointerLock) return;
  //   const chunk = getCurrentChunk();
  //   chunk && claim(chunk);
  // });

  noa.inputs.bind("voxelexplorer", "B");
  noa.inputs.down.on("voxelexplorer", () => {
    if (!noa.container.hasPointerLock) return;
    window.open(network.network.config.blockExplorer);
  });

  noa.inputs.bind("spawn", "O");
  noa.inputs.down.on("spawn", () => {
    if (!noa.container.hasPointerLock) return;
    setComponent(PreTeleportPosition, SingletonEntity, playerPosition$.getValue());
    teleport(SPAWN_POINT);
    updateComponent(Tutorial, SingletonEntity, { teleport: false });
  });

  noa.inputs.bind("preteleport", "P");
  noa.inputs.down.on("preteleport", () => {
    if (!noa.container.hasPointerLock) return;
    const preTeleportPosition = getComponentValue(PreTeleportPosition, SingletonEntity);
    if (!preTeleportPosition) return;
    teleport(preTeleportPosition);
    updateComponent(Tutorial, SingletonEntity, { teleport: false });
  });

  noa.inputs.bind("plugins", ";");
  noa.inputs.down.on("plugins", () => {
    togglePlugins();
  });

  let hasSelectedCorner = false;
  let isSelectingVoxel = false;
  noa.inputs.bind("select-voxel", "V");
  noa.inputs.down.on("select-voxel", () => {
    isSelectingVoxel = true;
    hasSelectedCorner = false;
  });
  noa.inputs.up.on("select-voxel", () => {
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
    const voxelSelection = getComponentValue(VoxelSelection, SingletonEntity);
    const points: VoxelCoord[] = voxelSelection?.points ?? [];
    const coord = getTargetedVoxelCoord(noa);
    points.push(coord);

    toast(`Selected voxel at ${coord.x}, ${coord.y}, ${coord.z}`);
    setComponent(VoxelSelection, SingletonEntity, {
      points: points as any,
      corner1: voxelSelection?.corner1,
      corner2: voxelSelection?.corner2,
    });
  });

  noa.inputs.bind("clearSelectedPointVoxels", "<backspace>", "<delete>");
  noa.inputs.down.on("clearSelectedPointVoxels", () => {
    setComponent(VoxelSelection, SingletonEntity, {
      points: [] as any,
      corner1: undefined,
      corner2: undefined,
    });
  });

  noa.inputs.bind("spawnCreation", "<enter>");
  noa.inputs.down.on("spawnCreation", () => {
    if (!noa.container.hasPointerLock) {
      return;
    }
    const creationToSpawn: Creation | undefined = getComponentValue(SpawnCreation, SingletonEntity)?.creation;
    if (creationToSpawn === undefined) {
      return;
    }
    const lowerSouthWestCorner = getCoordOfVoxelOnFaceYouTargeted(noa);
    spawnCreation(lowerSouthWestCorner, (creationToSpawn as Creation).creationId);

    // clear the spawn creation component so the outline disappears
    // TODO: wait until the transaction succeeds, then clear the spawn creation component
    setComponent(SpawnCreation, SingletonEntity, { creation: undefined });
    // clear the persistent notification
    setComponent(PersistentNotification, SingletonEntity, {
      message: "",
      icon: NotificationIcon.NONE,
    });
  });
}
