import { defineComponent, Type, World } from "@latticexyz/recs";

export function definePlayerRelayerChunkPositionComponent(world: World) {
  return defineComponent(world, { x: Type.Number, y: Type.Number }, { id: "PlayerRelayerChunkPosition" });
}
