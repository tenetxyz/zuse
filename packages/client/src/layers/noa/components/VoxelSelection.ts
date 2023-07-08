import { defineComponent, Type, World } from "@latticexyz/recs";
export function defineVoxelSelectionComponent(world: World) {
  return defineComponent(
    world,
    {
      corner1: Type.OptionalT, // a voxelCoord
      corner2: Type.OptionalT, // a voxelCoord
    },
    { id: "VoxelSelectionComponent" }
  );
}
