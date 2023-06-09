import { SyncState } from "@latticexyz/network";
import {
  defineComponentSystem,
  defineEnterSystem,
  getComponentValueStrict,
  Has,
} from "@latticexyz/recs";
import { awaitStreamValue } from "@latticexyz/utils";
import { NetworkLayer } from "../../network";
import { NoaLayer } from "../types";

export async function createBlockSystem(
  network: NetworkLayer,
  context: NoaLayer
) {
  const {
    api: { setBlock },
  } = context;

  const {
    world,
    components: { LoadingState },
    contractComponents: { VoxelType, Position },
    actions: { withOptimisticUpdates },
    api: { getBlockAtPosition },
  } = network;

  const OptimisticPosition = Position;
  const OptimisticVoxelType = VoxelType;

  // Loading state flag
  let live = false;
  awaitStreamValue(
    LoadingState.update$,
    ({ value }) => value[0]?.state === SyncState.LIVE
  ).then(() => (live = true));

  // "Exit system"
  defineComponentSystem(world, OptimisticPosition, async ({ value }) => {
    if (!live) return;
    if (!value[0] && value[1]) {
      const block = getBlockAtPosition(value[1]);
      setBlock(value[1], block);
    }
  });

  // "Enter system"
  defineEnterSystem(
    world,
    [Has(OptimisticPosition), Has(OptimisticVoxelType)],
    (update) => {
      if (!live) return;
      const position = getComponentValueStrict(
        OptimisticPosition,
        update.entity
      );
      const block = getBlockAtPosition(position);
      setBlock(position, block);
    }
  );
}
