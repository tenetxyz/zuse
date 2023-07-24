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
export const TILE_ID = keccak256("tile");
export const TILE2_ID = keccak256("tile2");

export function Air({ coord: { y } }: TerrainState): VoxelTypeDataKey | undefined {
  if (y > 10)
    return {
      voxelTypeNamespace: TENET_NAMESPACE,
      voxelTypeId: AIR_ID,
      voxelVariantNamespace: TENET_NAMESPACE,
      voxelVariantId: AIR_ID,
    };
}

export function Bedrock({ coord: { y } }: TerrainState): VoxelTypeDataKey | undefined {
  if (y <= -63)
    return {
      voxelTypeNamespace: TENET_NAMESPACE,
      voxelTypeId: BEDROCK_ID,
      voxelVariantNamespace: TENET_NAMESPACE,
      voxelVariantId: BEDROCK_ID,
    };
}

export function Tile(state: TerrainState): VoxelTypeDataKey | undefined {
  const {
    coord: { x, y, z },
  } = state;

  if (y > -63 && y <= 10 && (x + z) % 2 != 0) {
    return {
      voxelTypeNamespace: TENET_NAMESPACE,
      voxelTypeId: TILE_ID,
      voxelVariantNamespace: TENET_NAMESPACE,
      voxelVariantId: TILE_ID,
    };
  }
}

export function Tile2(state: TerrainState): VoxelTypeDataKey | undefined {
  const {
    coord: { x, y, z },
  } = state;

  if (y > -63 && y <= 10 && (x + z) % 2 == 0) {
    return {
      voxelTypeNamespace: TENET_NAMESPACE,
      voxelTypeId: TILE2_ID,
      voxelVariantNamespace: TENET_NAMESPACE,
      voxelVariantId: TILE2_ID,
    };
  }
}
