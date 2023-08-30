import { defineComponent, Type, World } from "@latticexyz/recs";

export function definePlayerPositionComponent(world: World) {
  return defineComponent(world, { x: Type.Number, y: Type.Number, z: Type.Number }, { id: "PlayerPosition" });
}
