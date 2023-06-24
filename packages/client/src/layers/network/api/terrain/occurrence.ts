import { Entity } from "@latticexyz/recs";
import { STRUCTURE_CHUNK, Biome } from "./constants";
import { getStructureVoxel, WoolTree, Tree } from "./structures";
import { TerrainState } from "./types";
import { accessState } from "./utils";
import { keccak256 } from "@latticexyz/utils";
import { VoxelTypeDataKey } from "../../../noa/types";

export function Air({ coord: { y } }: TerrainState): VoxelTypeDataKey | undefined {
  if (y > 10) return {
    namespace: "tenet",
    voxelType: keccak256("air"),
    voxelVariantId: keccak256("air")
  };
}

export function Bedrock({ coord: { y } }: TerrainState): VoxelTypeDataKey | undefined {
  if (y <= -63) return {
    namespace: "tenet",
    voxelType: keccak256("bedrock"),
    voxelVariantId: keccak256("bedrock")
  };
}

export function Grass(state: TerrainState): VoxelTypeDataKey | undefined {
  const {
    coord: { y },
  } = state;

  if (y == 10) return  {
    namespace: "tenet",
    voxelType: keccak256("grass"),
    voxelVariantId: keccak256("grass")
  };
}

export function Dirt(state: TerrainState): VoxelTypeDataKey | undefined {
  const {
    coord: { y },
  } = state;

  if (y > -63 && y < 10) return {
    namespace: "tenet",
    voxelType: keccak256("dirt"),
    voxelVariantId: keccak256("dirt")
  };
}
