import { defineComponent, Type, World } from "@latticexyz/recs";

export function defineVoxelTypeComponent(world: World) {
  return defineComponent(
    world,
    { value: Type.String },
    {
      id: "VoxelType",
      metadata: { contractId: "component.VoxelType" },
    }
  );
}
