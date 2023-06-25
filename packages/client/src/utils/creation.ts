import { Creation } from "../layers/react/components/CreationStore";
import { VoxelCoord } from "@latticexyz/utils";

export const calculateMinMaxRelativeCoordsOfCreation = (
  creation: Creation
): { minRelativeCoord: VoxelCoord; maxRelativeCoord: VoxelCoord } => {
  return calculateMinMaxRelativePositions(creation.relativePositions);
};
export const calculateMinMaxRelativePositions = (
  relativePositions: VoxelCoord[]
): { minRelativeCoord: VoxelCoord; maxRelativeCoord: VoxelCoord } => {
  // creations should have at least 2 voxels, so we can assume the first one is the min and max
  const minCoord: VoxelCoord = { ...relativePositions[0] }; // clone the coord so we don't mutate the original
  const maxCoord: VoxelCoord = { ...relativePositions[0] };

  for (let i = 1; i < relativePositions.length; i++) {
    const voxelCoord = relativePositions[i];
    minCoord.x = Math.min(minCoord.x, voxelCoord.x);
    minCoord.y = Math.min(minCoord.y, voxelCoord.y);
    minCoord.z = Math.min(minCoord.z, voxelCoord.z);
    maxCoord.x = Math.max(maxCoord.x, voxelCoord.x);
    maxCoord.y = Math.max(maxCoord.y, voxelCoord.y);
    maxCoord.z = Math.max(maxCoord.z, voxelCoord.z);
  }
  return {
    minRelativeCoord: minCoord,
    maxRelativeCoord: maxCoord,
  };
};
