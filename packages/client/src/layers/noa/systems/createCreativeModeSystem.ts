import { defineComponentSystem } from "@latticexyz/recs";
import { NetworkLayer } from "../../network";
import { NoaLayer } from "../types";

export function createCreativeModeSystem(network: NetworkLayer, context: NoaLayer) {
  const { noa, SingletonEntity } = context;

  const {
    world,
    components: { GameConfig },
  } = network;

  defineComponentSystem(world, GameConfig, (update) => {
    const entity = update.entity;
    if (entity !== SingletonEntity) return;
    const currentValue = update.value[0];
    const movementComponent = noa.ents.getMovement(noa.playerEntity);
    if (currentValue?.creativeMode) {
      movementComponent.state.maxJumps = 999;
    } else {
      movementComponent.state.maxJumps = 2;
    }
  });
}
