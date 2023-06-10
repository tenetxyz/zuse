import {
  getComponentValue,
  HasValue,
  runQuery,
  setComponent,
  updateComponent,
} from "@latticexyz/recs";
import { sleep, VoxelCoord } from "@latticexyz/utils";
import { NetworkLayer, VoxelTypeKeyToId } from "../../network";
import { FAST_MINING_DURATION, SPAWN_POINT } from "../constants";
import {
  HandComponent,
  HAND_COMPONENT,
} from "../engine/components/handComponent";
import {
  MiningVoxelComponent,
  MINING_VOXEL_COMPONENT,
} from "../engine/components/miningVoxelComponent";
import {
  getNoaComponent,
  getNoaComponentStrict,
} from "../engine/components/utils";
import { NoaLayer } from "../types";
import { toast } from "react-toastify";
import { renderChunkyWireframe } from "./renderWireframes";

export function createInputSystem(network: NetworkLayer, context: NoaLayer) {
  const {
    noa,
    components: {
      SelectedSlot,
      UI,
      Tutorial,
      PreTeleportPosition,
      VoxelSelection,
    },
    SingletonEntity,
    api: {
      toggleInventory,
      togglePlugins,
      placeSelectedVoxelType,
      getCurrentChunk,
      getVoxelTypeInSelectedSlot,
      teleport,
    },
    streams: { stakeAndClaim$, playerPosition$ },
  } = context;

  const {
    contractComponents: { VoxelType, Position },
    // api: { stake, claim },
    network: { connectedAddress },
    streams: { balanceGwei$ },
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
      const handComponent = getNoaComponentStrict<HandComponent>(
        noa,
        noa.playerEntity,
        HAND_COMPONENT
      );
      if (miningComponent.active) {
        return;
      }
      miningComponent.active = true;
      handComponent.isMining;
      miningComponent.coord = { x: pos[0], y: pos[1], z: pos[2] };

      if (creativeMode) {
        miningComponent.duration = 10;
      } else if (getVoxelTypeInSelectedSlot() === VoxelTypeKeyToId.Bedrock) {
        miningComponent.duration = FAST_MINING_DURATION;
      }
      return miningComponent;
    }
  }

  let firePressed = false;
  noa.inputs.down.on("fire", async function () {
    if (!noa.container.hasPointerLock) return;

    firePressed = true;
    const miningComponent = mineTargetedVoxel();
    while (firePressed) {
      if (!miningComponent?.duration) return;
      await sleep(miningComponent.duration + 100);
      if (firePressed) mineTargetedVoxel();
    }
  });

  noa.inputs.up.on("fire", function () {
    if (!noa.container.hasPointerLock) return;

    firePressed = false;
    const miningComponent = getNoaComponentStrict<MiningVoxelComponent>(
      noa,
      noa.playerEntity,
      MINING_VOXEL_COMPONENT
    );
    const handComponent = getNoaComponentStrict<HandComponent>(
      noa,
      noa.playerEntity,
      HAND_COMPONENT
    );
    miningComponent.active = false;
    handComponent.isMining = false;
  });

  noa.on("targetVoxelChanged", (targetedVoxel: { position: number[] }) => {
    if (!noa.container.hasPointerLock) return;

    const miningComponent = getNoaComponent<MiningVoxelComponent>(
      noa,
      noa.playerEntity,
      MINING_VOXEL_COMPONENT
    );
    if (!miningComponent) return;
    const handComponent = getNoaComponentStrict<HandComponent>(
      noa,
      noa.playerEntity,
      HAND_COMPONENT
    );
    if (!targetedVoxel) {
      return;
    }
    const {
      position: [x, y, z],
    } = targetedVoxel;
    if (
      miningComponent.coord.x !== x ||
      miningComponent.coord.y !== y ||
      miningComponent.coord.z !== z
    ) {
      miningComponent.active = false;
      handComponent.isMining = false;
    }
  });

  // place a voxel on right click
  noa.inputs.unbind("alt-fire"); // Unbind to remove the default binding of "E"
  noa.inputs.bind("alt-fire", "<mouse 3>", "R");

  noa.inputs.down.on("alt-fire", function () {
    if (!noa.container.hasPointerLock) return;

    if (noa.targetedBlock) {
      const pos = noa.targetedBlock.adjacent;
      const targeted = noa.targetedBlock.position;

      // Open crafting UI if the targeted voxel is a crafting table
      if (
        runQuery([
          HasValue(Position, {
            x: targeted[0],
            y: targeted[1],
            z: targeted[2],
          }),
          HasValue(VoxelType, { value: VoxelTypeKeyToId.Crafting }),
        ]).size > 0
      ) {
        return toggleInventory(true, true);
      }
      if (!canInteract()) return;
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
    const showAdminPanel = getComponentValue(
      UI,
      SingletonEntity
    )?.showAdminPanel;
    updateComponent(UI, SingletonEntity, {
      showAdminPanel: !showAdminPanel,
    });
  });

  noa.inputs.bind("inventory", "E");
  noa.inputs.down.on("inventory", () => {
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
    setComponent(
      PreTeleportPosition,
      SingletonEntity,
      playerPosition$.getValue()
    );
    teleport(SPAWN_POINT);
    updateComponent(Tutorial, SingletonEntity, { teleport: false });
  });

  noa.inputs.bind("preteleport", "P");
  noa.inputs.down.on("preteleport", () => {
    if (!noa.container.hasPointerLock) return;
    const preTeleportPosition = getComponentValue(
      PreTeleportPosition,
      SingletonEntity
    );
    if (!preTeleportPosition) return;
    teleport(preTeleportPosition);
    updateComponent(Tutorial, SingletonEntity, { teleport: false });
  });

  noa.inputs.bind("plugins", ";");
  noa.inputs.down.on("plugins", () => {
    togglePlugins();
  });

  noa.inputs.bind("select-voxel", "V");
  noa.inputs.down.on("select-voxel", () => {
    // print the voxel you're looking at to the console
    if (!noa.targetedBlock) {
      return;
    }
    const points: VoxelCoord[] =
      getComponentValue(VoxelSelection, SingletonEntity)?.points ?? [];
    const x = noa.targetedBlock.position[0];
    const y = noa.targetedBlock.position[1];
    const z = noa.targetedBlock.position[2];
    points.push({
      x,
      y,
      z,
    });
    renderChunkyWireframe(points.at(-1)!, points.at(-1)!, noa);
    toast(`Selected voxel at ${x}, ${y}, ${z}`);
    setComponent(VoxelSelection, SingletonEntity, { points: points as any });
  });
}
