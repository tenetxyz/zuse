import { Entity } from "@latticexyz/recs";
import { STRUCTURE_CHUNK, Biome } from "./constants";
import { getStructureVoxel, WoolTree, Tree } from "./structures";
import { TerrainState } from "./types";
import { accessState } from "./utils";
import { keccak256 } from "@latticexyz/utils";
import { VoxelTypeDataKey } from "../../../noa/types";
import { TENET_NAMESPACE } from "../../../../constants";

export const AIR_ID = keccak256("air");
export const BEDROCK_ID = keccak256("bedrock");
export const GRASS_ID = keccak256("grass");
export const DIRT_ID = keccak256("dirt");

export function Air({ coord: { y } }: TerrainState): VoxelTypeDataKey | undefined {
  if (y > 10) return {
    voxelTypeNamespace: TENET_NAMESPACE,
    voxelTypeId: AIR_ID,
    voxelVariantNamespace: TENET_NAMESPACE,
    voxelVariantId: AIR_ID,
  };
}

export function Bedrock({ coord: { y } }: TerrainState): VoxelTypeDataKey | undefined {
  if (y <= -63) return {
    voxelTypeNamespace: TENET_NAMESPACE,
    voxelTypeId: BEDROCK_ID,
    voxelVariantNamespace: TENET_NAMESPACE,
    voxelVariantId: BEDROCK_ID,
  };
}

export function Grass(state: TerrainState): VoxelTypeDataKey | undefined {
  const {
    coord: { y },
  } = state;

  if (y == 10) return  {
    voxelTypeNamespace: TENET_NAMESPACE,
    voxelTypeId: GRASS_ID,
    voxelVariantNamespace: TENET_NAMESPACE,
    voxelVariantId: GRASS_ID,
  };
}

export function Dirt(state: TerrainState): VoxelTypeDataKey | undefined {
  const {
    coord: { y },
  } = state;

  if (y > -63 && y < 10) return {
    voxelTypeNamespace: TENET_NAMESPACE,
    voxelTypeId: DIRT_ID,
    voxelVariantNamespace: TENET_NAMESPACE,
    voxelVariantId: DIRT_ID,
  };
}
