import { defineComponent, Type, World } from "@latticexyz/recs";
export function defineVoxelInterfaceSelectionComponent(world: World) {
  return defineComponent(
    world,
    {
      interfaceVoxels: Type.OptionalT, // InterfaceVoxel[]
      selectingVoxelIdx: Type.Number, // index of the current InterfaceVoxel being selected
    },
    { id: "VoxelInterfaceSelectionComponent" }
  );
}
