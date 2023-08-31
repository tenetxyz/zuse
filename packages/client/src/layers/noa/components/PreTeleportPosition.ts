import { defineComponent, Type, World } from "@latticexyz/recs";

export function definePreTeleportPositionComponent(world: World) {
  return defineComponent(world, { x: Type.Number, y: Type.Number, z: Type.Number }, { id: "PreTeleportPosition" });
}
