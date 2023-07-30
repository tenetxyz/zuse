import { VoxelCoord } from "@latticexyz/utils";
import { Creation } from "../layers/react/components/CreationStore";
import { abiDecode } from "./abi";
import { Entity, getComponentValueStrict } from "@latticexyz/recs";
import { decodeBaseCreations } from "./encodeOrDecode";
import { Engine } from "noa-engine";

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

export const calculateMinMaxRelativeCoordsOfCreation = (Creation: any, creationId: Entity) => {
  const relativeVoxelCoords = getVoxelCoordsOfCreation(Creation, creationId);
  return calculateMinMaxCoords(relativeVoxelCoords);
};

// TODO: fix the type of Creation:any. Note: I didn't want to pass in "layers" since this function is called a lot, and we'd be dereferencing layers a lot to get Creation
export const getVoxelCoordsOfCreation = (Creation: any, creationId: Entity): VoxelCoord[] => {
  // PERF: if users tend to spawn the same creation multiple times we should memoize the creation fetching process
  const creation = getComponentValueStrict(Creation, creationId);

  // 1) Add the voxel coords from the creation itself
  const voxelCoords =
    (abiDecode("tuple(uint32 x,uint32 y,uint32 z)[]", creation.relativePositions) as VoxelCoord[]) || [];
  const baseCreations = decodeBaseCreations(creation.baseCreations);

  // 2) add the voxel coords from the base creations
  for (const baseCreation of baseCreations) {
    const baseCreationVoxelCoords = getVoxelCoordsOfCreation(Creation, baseCreation.creationId);
    const uniqueCoords = new Set<string>(baseCreationVoxelCoords.map(voxelCoordToString));
    for (const deletedRelativeCoord of baseCreation.deletedRelativeCoords) {
      uniqueCoords.delete(voxelCoordToString(deletedRelativeCoord));
    }
    voxelCoords.push(
      ...Array.from(uniqueCoords)
        .map(stringToVoxelCoord)
        .map((voxelCoord) => add(voxelCoord, baseCreation.coordOffset))
    );
  }
  return voxelCoords;
};

const calculateMinMaxCoords = (coords: VoxelCoord[]): { minCoord: VoxelCoord; maxCoord: VoxelCoord } => {
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

export const getWorldScale = (noa: Engine): number => {
  return parseInt(noa.worldName);
};

export const getPositionInLevelAbove = (position: VoxelCoord): VoxelCoord => {
  return { x: position.x / 2, y: position.y / 2, z: position.z / 2 };
};
export const getPositionInLevelBelow = (position: VoxelCoord): VoxelCoord => {
  return { x: position.x * 2, y: position.y * 2, z: position.z * 2 };
};
export const getPositionInLevel1Scale = (position: VoxelCoord, scale: number): VoxelCoord => {
  const numberOfMultiplications = Math.pow(2, scale - 1);
  return {
    x: position.x * numberOfMultiplications,
    y: position.y * numberOfMultiplications,
    z: position.z * numberOfMultiplications,
  };
};

export function calculateChildCoords(parentCoord: VoxelCoord, scale: number): VoxelCoord[] {
  // Since the side length of
  const childCoords: VoxelCoord[] = new Array<VoxelCoord>(scale * scale * scale);
  let index = 0;
  for (let dz = 0; dz < 2; dz++) {
    for (let dy = 0; dy < 2; dy++) {
      for (let dx = 0; dx < 2; dx++) {
        childCoords[index] = {
          x: parentCoord.x * scale + dx,
          y: parentCoord.y * scale + dy,
          z: parentCoord.z * scale + dz,
        };
        index++;
      }
    }
  }
  return childCoords;
}

export function calculateParentCoord(childCoord: VoxelCoord, scale: number): VoxelCoord {
  const parentCoord: VoxelCoord = {
    x: Math.floor(childCoord.x / scale),
    y: Math.floor(childCoord.y / scale),
    z: Math.floor(childCoord.z / scale),
  };
  return parentCoord;
}
