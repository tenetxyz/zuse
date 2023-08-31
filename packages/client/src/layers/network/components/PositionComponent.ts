import { defineComponent, Type, World } from "@latticexyz/recs";

export function definePositionComponent(world: World) {
  return defineComponent(
    world,
    { x: Type.Number, y: Type.Number, z: Type.Number },
    {
      id: "Position",
      metadata: { contractId: "component.Position" },
    }
  );
}
