import { TerrainState } from "./types";
import { keccak256 } from "@latticexyz/utils";
import { VoxelTypeKey } from "../../../noa/types";
import { calculateParentCoord } from "../../../../utils/coord";

export const AIR_ID = keccak256("air");
export const BEDROCK_ID = keccak256("bedrock");
export const GRASS_ID = keccak256("grass");
export const DIRT_ID = keccak256("dirt");
export const TILE2_ID = keccak256("tile2");
export const TILE3_ID = keccak256("tile3");
export const TILE4_ID = keccak256("tile4");

const TILE_HEIGHT = 9;
const BEDROCK_HEIGHT = -63;

export function Air({ coord: { y }, scale }: TerrainState): VoxelTypeKey | undefined {
  const GRASS_Y = calculateParentCoord({ x: 0, y: TILE_HEIGHT, z: 0 }, scale).y;
  if (y > GRASS_Y)
    return {
      voxelBaseTypeId: AIR_ID,
      voxelVariantTypeId: AIR_ID,
    };
}

export function Bedrock({ coord: { y }, scale }: TerrainState): VoxelTypeKey | undefined {
  const BEDROCK_Y = calculateParentCoord({ x: 0, y: BEDROCK_HEIGHT, z: 0 }, scale).y;
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
  const tileY = calculateParentCoord({ x: 0, y: TILE_HEIGHT, z: 0 }, scale).y;

  if (y !== tileY) {
    return;
  }
  switch (scale) {
    case 1:
      return {
        voxelBaseTypeId: GRASS_ID,
        voxelVariantTypeId: GRASS_ID,
      };
    case 2:
      return {
        voxelBaseTypeId: TILE2_ID,
        voxelVariantTypeId: TILE2_ID,
      };
    case 3:
      return {
        voxelBaseTypeId: TILE3_ID,
        voxelVariantTypeId: TILE3_ID,
      };
    default:
      return {
        voxelBaseTypeId: TILE4_ID,
        voxelVariantTypeId: TILE4_ID,
      };
  }
}

export function Dirt(state: TerrainState): VoxelTypeKey | undefined {
  const {
    coord: { y },
    scale,
  } = state;
  const BEDROCK_Y = calculateParentCoord({ x: 0, y: BEDROCK_HEIGHT, z: 0 }, scale).y;
  const GRASS_Y = calculateParentCoord({ x: 0, y: TILE_HEIGHT, z: 0 }, scale).y;

  if (y > BEDROCK_Y && y < GRASS_Y)
    return {
      voxelBaseTypeId: DIRT_ID,
      voxelVariantTypeId: DIRT_ID,
    };
}
