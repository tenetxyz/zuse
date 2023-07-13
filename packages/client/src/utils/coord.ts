import { VoxelCoord } from "@latticexyz/utils";
import { Creation } from "../layers/react/components/CreationStore";
import { abiDecode } from "./abi";

export const ZERO_VECTOR: VoxelCoord = { x: 0, y: 0, z: 0 };

export function eq(a: VoxelCoord, b: VoxelCoord): boolean {
  if (a.x !== b.x || a.y !== b.y || a.z !== b.z) {
    return false;
  }
  return true;
}
export function mul(a: VoxelCoord, b: number): VoxelCoord {
  return { x: a.x * b, y: a.y * b, z: a.z * b };
}

export function add(a: VoxelCoord, b: VoxelCoord): VoxelCoord {
  return { x: a.x + b.x, y: a.y + b.y, z: a.z + b.z };
}

export function sub(a: VoxelCoord, b: VoxelCoord): VoxelCoord {
  return { x: a.x - b.x, y: a.y - b.y, z: a.z - b.z };
}

export function voxelCoordToString(coord: VoxelCoord): string {
  return `(${coord.x}, ${coord.y}, ${coord.z})`;
}
export function stringToVoxelCoord(coordString: string): VoxelCoord {
  const [xStr, yStr, zStr] = coordString.substring(1, coordString.length - 1).split(",");
  return {
    x: parseInt(xStr),
    y: parseInt(yStr),
    z: parseInt(zStr),
  };
}

export const calculateMinMaxRelativeCoordsOfCreation = (
  creation: Creation
): { minRelativeCoord: VoxelCoord; maxRelativeCoord: VoxelCoord } => {
  return calculateMinMaxCoords(creation.relativePositions);
};

export const calculateMinMaxCoords = (coords: VoxelCoord[]): { minCoord: VoxelCoord; maxCoord: VoxelCoord } => {
  // creations should have at least 2 voxels, so we can assume the first one is the min and max
  const minCoord: VoxelCoord = { ...coords[0] }; // clone the coord so we don't mutate the original
  const maxCoord: VoxelCoord = { ...coords[0] };

  for (let i = 1; i < coords.length; i++) {
    const voxelCoord = coords[i];
    minCoord.x = Math.min(minCoord.x, voxelCoord.x);
    minCoord.y = Math.min(minCoord.y, voxelCoord.y);
    minCoord.z = Math.min(minCoord.z, voxelCoord.z);
    maxCoord.x = Math.max(maxCoord.x, voxelCoord.x);
    maxCoord.y = Math.max(maxCoord.y, voxelCoord.y);
    maxCoord.z = Math.max(maxCoord.z, voxelCoord.z);
  }
  return {
    minCoord: minCoord,
    maxCoord: maxCoord,
  };
};

export const decodeCoord = (encodedCoord: string): VoxelCoord => {
  return abiDecode("tuple(int32 x,int32 y,int32 z)", encodedCoord) as VoxelCoord;
};
