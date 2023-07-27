import { TerrainState } from "./types";
import { keccak256 } from "@latticexyz/utils";
import { VoxelTypeKey } from "../../../noa/types";
import { calculateParentCoord } from "../../../../utils/coord";

export const AIR_ID = keccak256("air");
export const BEDROCK_ID = keccak256("bedrock");
export const GRASS_ID = keccak256("grass");
export const DIRT_ID = keccak256("dirt");

const GRASS_HEIGHT = 9;
const BEDROCK_HEIGHT = -63;

export function Air({ coord: { y }, scale }: TerrainState): VoxelTypeKey | undefined {
  const GRASS_Y = calculateParentCoord({ x: 0, y: GRASS_HEIGHT, z: 0 }, scale).y;
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

export function Grass(state: TerrainState): VoxelTypeKey | undefined {
  const {
    coord: { y },
    scale,
  } = state;
  const GRASS_Y = calculateParentCoord({ x: 0, y: GRASS_HEIGHT, z: 0 }, scale).y;

  if (y === GRASS_Y)
    return {
      voxelBaseTypeId: GRASS_ID,
      voxelVariantTypeId: GRASS_ID,
    };
}

export function Dirt(state: TerrainState): VoxelTypeKey | undefined {
  const {
    coord: { y },
    scale,
  } = state;
  const BEDROCK_Y = calculateParentCoord({ x: 0, y: BEDROCK_HEIGHT, z: 0 }, scale).y;
  const GRASS_Y = calculateParentCoord({ x: 0, y: GRASS_HEIGHT, z: 0 }, scale).y;

  if (y > BEDROCK_Y && y < GRASS_Y)
    return {
      voxelBaseTypeId: DIRT_ID,
      voxelVariantTypeId: DIRT_ID,
    };
}
