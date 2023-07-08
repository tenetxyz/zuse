import { defineComponent, Type, World } from "@latticexyz/recs";
export function defineVoxelInterfaceSelectionComponent(world: World) {
  return defineComponent(
    world,
    {
      value: Type.OptionalT, // a set<string> of voxelCoords (it needs to be a string so the set can hash them)
    },
    { id: "VoxelInterfaceSelectionComponent" }
  );
}
