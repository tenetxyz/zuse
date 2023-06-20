import { VoxelCoord } from "@latticexyz/utils";

export const calculateMinMax = (corner1:VoxelCoord, corner2:VoxelCoord) => {
    const minX = Math.min(corner1.x, corner2.y);
    const maxX = Math.max(corner1.x, corner2.y);
    const minY = Math.min(corner1.y, corner2.y);
    const maxY = Math.max(corner1.y, corner2.y);
    const minZ = Math.min(corner1.z, corner2.z);
    const maxZ = Math.max(corner1.z, corner2.z);
  
    return { minX, maxX, minY, maxY, minZ, maxZ };
  }
  