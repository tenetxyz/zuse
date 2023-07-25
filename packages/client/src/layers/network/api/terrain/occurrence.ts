import { TerrainState } from "./types";
import { keccak256 } from "@latticexyz/utils";
import { VoxelTypeKey } from "../../../noa/types";

export const AIR_ID = keccak256("air");
export const BEDROCK_ID = keccak256("bedrock");
export const GRASS_ID = keccak256("grass");
export const DIRT_ID = keccak256("dirt");

export function Air({ coord: { y } }: TerrainState): VoxelTypeKey | undefined {
  if (y > 10)
    return {
      voxelBaseTypeId: AIR_ID,
      voxelVariantTypeId: AIR_ID,
    };
}

export function Bedrock({ coord: { y } }: TerrainState): VoxelTypeKey | undefined {
  if (y <= -63)
    return {
      voxelBaseTypeId: BEDROCK_ID,
      voxelVariantTypeId: BEDROCK_ID,
    };
}

export function Grass(state: TerrainState): VoxelTypeKey | undefined {
  const {
    coord: { y },
  } = state;

  if (y == 10)
    return {
      voxelBaseTypeId: GRASS_ID,
      voxelVariantTypeId: GRASS_ID,
    };
}

export function Dirt(state: TerrainState): VoxelTypeKey | undefined {
  const {
    coord: { y },
  } = state;

  if (y > -63 && y < 10)
    return {
      voxelBaseTypeId: DIRT_ID,
      voxelVariantTypeId: DIRT_ID,
    };
}
