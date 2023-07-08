import { defineComponent, Type, World } from "@latticexyz/recs";
export function defineVoxelInterfaceSelectionComponent(world: World) {
  return defineComponent(
    world,
    {
      value: Type.OptionalT, // a set of voxelCoords
    },
    { id: "VoxelInterfaceSelectionComponent" }
  );
}
