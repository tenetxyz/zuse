import { Entity, ComponentValue, Type } from "@latticexyz/recs";
import { VoxelCoord } from "@latticexyz/utils";
import { Engine } from "noa-engine";

export const calculateMinMax = (corner1: VoxelCoord, corner2: VoxelCoord) => {
  const minX = Math.min(corner1.x, corner2.y);
  const maxX = Math.max(corner1.x, corner2.y);
  const minY = Math.min(corner1.y, corner2.y);
  const maxY = Math.max(corner1.y, corner2.y);
  const minZ = Math.min(corner1.z, corner2.z);
  const maxZ = Math.max(corner1.z, corner2.z);

  return { minX, maxX, minY, maxY, minZ, maxZ };
};

export const getTargetedVoxelCoord = (noa: Engine): VoxelCoord => {
  const x = noa.targetedBlock.position[0];
  const y = noa.targetedBlock.position[1];
  const z = noa.targetedBlock.position[2];
  return {
    x,
    y,
    z,
  };
};

export const getCoordOfVoxelOnFaceYouTargeted = (noa: Engine): VoxelCoord => {
  // adjacent just means the coord on the side of the block face you targeted
  const x = noa.targetedBlock.adjacent[0];
  const y = noa.targetedBlock.adjacent[1];
  const z = noa.targetedBlock.adjacent[2];
  return {
    x,
    y,
    z,
  };
};
