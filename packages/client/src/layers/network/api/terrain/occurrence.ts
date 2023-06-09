import { Entity } from "@latticexyz/recs";
import { VoxelTypeKeyToId } from "../../constants";
import { STRUCTURE_CHUNK, Biome } from "./constants";
import { getStructureBlock, WoolTree, Tree } from "./structures";
import { TerrainState } from "./types";
import { accessState } from "./utils";

export function Air({ coord: { y } }: TerrainState): Entity | undefined {
  if (y > 10) return VoxelTypeKeyToId.Air;
}

export function Bedrock({ coord: { y } }: TerrainState): Entity | undefined {
  if (y <= -63) return VoxelTypeKeyToId.Bedrock;
}

export function Grass(state: TerrainState): Entity | undefined {
  const {
    coord: { y },
  } = state;

  if (y == 10) return VoxelTypeKeyToId.Grass;
}

export function Dirt(state: TerrainState): Entity | undefined {
  const {
    coord: { y },
  } = state;

  if (y > -63 && y < 10) return VoxelTypeKeyToId.Dirt;
}
