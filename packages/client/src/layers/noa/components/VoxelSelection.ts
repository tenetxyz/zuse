import { defineComponent, Type, World } from "@latticexyz/recs";
import { VoxelCoord } from "@latticexyz/utils";

export interface IVoxelSelection {
  points?: VoxelCoord[];
  corner1?: VoxelCoord;
  corner2?: VoxelCoord;
}

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
