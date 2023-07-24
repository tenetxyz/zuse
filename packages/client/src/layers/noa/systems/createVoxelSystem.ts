import { SyncState } from "@latticexyz/network";
import {
  defineComponentSystem,
  defineEnterSystem,
  getComponentValue,
  getComponentValueStrict,
  Has,
} from "@latticexyz/recs";
import { awaitStreamValue } from "@latticexyz/utils";
import { NetworkLayer } from "../../network";
import { NoaLayer } from "../types";

export async function createVoxelSystem(network: NetworkLayer, context: NoaLayer) {
  const {
    api: { setVoxel },
  } = context;

  const {
    world,
    components: { LoadingState },
    contractComponents: { VoxelType, Position },
    actions: { withOptimisticUpdates },
    api: { getVoxelAtPosition },
  } = network;

  // Loading state flag
  let live = false;
  awaitStreamValue(LoadingState.update$, ({ value }) => value[0]?.state === SyncState.LIVE).then(() => (live = true));

  defineComponentSystem(world, VoxelType, async (update) => {
    if (!live) return;
    if (!update.value[0] || !update.value[1]) return;
    const position = getComponentValue(Position, update.entity);
    if (!position) return; // if there's no position, the voxel is not in the world. so no need to display it
    setVoxel(position, update.value[0].voxelVariantId);
  });

  // "Exit system"
  defineComponentSystem(world, Position, async ({ value }) => {
    if (!live) return;
    if (!value[0] && value[1]) {
      const voxel = getVoxelAtPosition(value[1]);
      setVoxel(value[1], voxel);
    }
  });

  // "Enter system"
  defineEnterSystem(world, [Has(Position), Has(VoxelType)], (update) => {
    if (!live) return;
    const position = getComponentValueStrict(Position, update.entity);
    const voxel = getVoxelAtPosition(position);
    setVoxel(position, voxel.voxelVariantTypeId);
  });
}
