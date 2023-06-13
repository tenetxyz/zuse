import { defineComponent, Type, World } from "@latticexyz/recs";

export function defineVoxelSelectionComponent(world: World) {
  return defineComponent(
    world,
    {
      points: Type.OptionalT, // the type is an array of voxelcoords
      corner1: Type.OptionalT, // a voxelCoord
      corner2: Type.OptionalT, // a voxelCoord
    },
    { id: "VoxelSelectionComponent" }
  );
}
