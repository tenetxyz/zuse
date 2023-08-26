import { defineComponent, Type, World } from "@latticexyz/recs";

export function defineVoxelPrototypeComponent(world: World) {
  return defineComponent(
    world,
    { value: Type.Boolean },
    {
      id: "VoxelPrototype",
      metadata: { contractId: "component.VoxelPrototype" },
    }
  );
}
