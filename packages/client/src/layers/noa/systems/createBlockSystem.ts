import { SyncState } from "@latticexyz/network";
import { defineComponentSystem, defineEnterSystem, getComponentValueStrict, Has, getEntitiesWithValue } from "@latticexyz/recs";
import { awaitStreamValue } from "@latticexyz/utils";
import { NetworkLayer } from "../../network";
import { NoaLayer } from "../types";

export async function createBlockSystem(network: NetworkLayer, context: NoaLayer) {
  const {
    api: { setBlock },
  } = context;

  const {
    world,
    components: { LoadingState },
    contractComponents: { Item, Position },
    actions: { withOptimisticUpdates },
    api: { getBlockAtPosition },
  } = network;

  const OptimisticPosition = withOptimisticUpdates(Position);
  const OptimisticItem = withOptimisticUpdates(Item);

  // Loading state flag
  let live = false;
  awaitStreamValue(LoadingState.update$, ({ value }) => value[0]?.state === SyncState.LIVE).then(() => (live = true));

  // "Exit system"
  defineComponentSystem(world, OptimisticPosition, async ({ value }) => {
    if (!live) return;
    if (!value[0] && value[1]) {
      const block = getBlockAtPosition(value[1]);
      setBlock(value[1], block);
    }
  });

  // "Enter system"
  defineEnterSystem(world, [Has(OptimisticPosition), Has(OptimisticItem)], (update) => {
    if (!live) return;
    const position = getComponentValueStrict(OptimisticPosition, update.entity);
    console.log("enter world");
    console.log(update.entity);
    const entitiesAtPosition = [...getEntitiesWithValue(OptimisticPosition, position)];
    console.log(entitiesAtPosition);
    const block = getBlockAtPosition(position);
    console.log(block);
    setBlock(position, block);
  });
}
