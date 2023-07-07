import { getComponentValue } from "@latticexyz/recs";
import { VoxelCoord } from "@latticexyz/utils";
import { Engine } from "noa-engine";
import { Layers } from "../types";

export const calculateMinMax = (corner1: VoxelCoord, corner2: VoxelCoord) => {
  const minX = Math.min(corner1.x, corner2.x);
  const maxX = Math.max(corner1.x, corner2.x);
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

// Note: this type is only a subset of the actual value we get back from Noa. I only extracted the useful fields into this type
export type TargetedBlock = {
  adjacent: [number, number, number]; // the coord of the adjacent block we're looking at
  normal: [number, number, number]; // tells us which blockface we're looking at
  // all indexes are 0, except for the side we're looking at. I think a 1 means we're looking at side facing the positive end of that axis
  position: [number, number, number];
  blockId: number; // the noa blockId
};

export const getTargetedSpawnId = (layers: Layers, targetedBlock: TargetedBlock): String | undefined => {
  const {
    network: {
      contractComponents: { OfSpawn },
      api: { getEntityAtPosition },
    },
  } = layers;
  if (!targetedBlock) {
    return undefined;
  }
  const position = targetedBlock.position;
  // if this block is a spawn, then get the spawnId
  const entityAtPosition = getEntityAtPosition({ x: position[0], y: position[1], z: position[2] });
  if (!entityAtPosition) {
    return undefined;
  }
  return getComponentValue(OfSpawn, entityAtPosition)?.value;
};
