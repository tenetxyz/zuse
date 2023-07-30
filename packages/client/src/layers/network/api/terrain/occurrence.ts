import { TerrainState } from "./types";
import { keccak256 } from "@latticexyz/utils";
import { VoxelTypeKey } from "../../../noa/types";
import { calculateParentCoord, getPositionInLevel1Scale } from "../../../../utils/coord";

export const AIR_ID = keccak256("air");
export const BEDROCK_ID = keccak256("bedrock");
export const GRASS_ID = keccak256("grass");
export const TILE1_ID = keccak256("tile1"); // NOTE: these tiles are not in the registry. They are only client-side so the player has a surface to place blocks on. (also so the floors looks different when they zoom out)
export const DIRT_ID = keccak256("dirt");
export const TILE3_ID = keccak256("tile3");
export const TILE4_ID = keccak256("tile4");
export const TILE5_ID = keccak256("tile5");

export const TILE_HEIGHT = 0; // height at level 1. Note: if this is nonzero, we need to use getPositionInLevel1Scale in the functions below (when comparing the y)
const BEDROCK_HEIGHT = -128;

export function getBedrockHeight(scale: number): number {
  // This logic doesn't match with the contracts rn, cause the contracts doens't consider scale (thinks that it's -128). whatever
  return getPositionInLevel1Scale({ x: 0, y: BEDROCK_HEIGHT, z: 0 }, scale).y;
}

export function Air({ coord: { y }, scale }: TerrainState): VoxelTypeKey | undefined {
  if (y > TILE_HEIGHT)
    return {
      voxelBaseTypeId: AIR_ID,
      voxelVariantTypeId: AIR_ID,
    };
}

export function Bedrock({ coord: { y }, scale }: TerrainState): VoxelTypeKey | undefined {
  const BEDROCK_Y = getBedrockHeight(scale);
  if (y <= BEDROCK_Y)
    return {
      voxelBaseTypeId: BEDROCK_ID,
      voxelVariantTypeId: BEDROCK_ID,
    };
}

export function Tile(state: TerrainState): VoxelTypeKey | undefined {
  const {
    coord: { y },
    scale,
  } = state;

  if (y !== TILE_HEIGHT) {
    return;
  }
  switch (scale) {
    case 1:
      return {
        voxelBaseTypeId: TILE1_ID,
        voxelVariantTypeId: TILE1_ID,
      };
    case 2:
      return {
        voxelBaseTypeId: GRASS_ID,
        voxelVariantTypeId: GRASS_ID,
      };
    case 3:
      return {
        voxelBaseTypeId: TILE3_ID,
        voxelVariantTypeId: TILE3_ID,
      };
    case 4:
      return {
        voxelBaseTypeId: TILE4_ID,
        voxelVariantTypeId: TILE4_ID,
      };
    default:
      return {
        voxelBaseTypeId: TILE5_ID,
        voxelVariantTypeId: TILE5_ID,
      };
  }
}

export function Dirt(state: TerrainState): VoxelTypeKey | undefined {
  const {
    coord: { y },
    scale,
  } = state;
  const BEDROCK_Y = getBedrockHeight(scale);

  if (y <= BEDROCK_Y || y >= TILE_HEIGHT) {
    return;
  }
  if (scale === 2) {
    return {
      voxelBaseTypeId: DIRT_ID,
      voxelVariantTypeId: DIRT_ID,
    };
  } else {
    return {
      voxelBaseTypeId: TILE1_ID,
      voxelVariantTypeId: TILE1_ID,
    };
  }
}
