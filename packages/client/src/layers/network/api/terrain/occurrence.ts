import { Entity } from "@latticexyz/recs";
import { STRUCTURE_CHUNK, Biome } from "./constants";
import { getStructureVoxel, WoolTree, Tree } from "./structures";
import { TerrainState } from "./types";
import { accessState } from "./utils";
import { keccak256 } from "@latticexyz/utils";
import { VoxelTypeDataKey } from "../../../noa/types";
import { TENET_NAMESPACE } from "../../../../constants";

export function Air({ coord: { y } }: TerrainState): VoxelTypeDataKey | undefined {
  if (y > 10) return {
    voxelTypeNamespace: TENET_NAMESPACE,
    voxelTypeId: keccak256("air"),
    voxelVariantNamespace: TENET_NAMESPACE,
    voxelVariantId: keccak256("air")
  };
}

export function Bedrock({ coord: { y } }: TerrainState): VoxelTypeDataKey | undefined {
  if (y <= -63) return {
    voxelTypeNamespace: TENET_NAMESPACE,
    voxelTypeId: keccak256("bedrock"),
    voxelVariantNamespace: TENET_NAMESPACE,
    voxelVariantId: keccak256("bedrock")
  };
}

export function Grass(state: TerrainState): VoxelTypeDataKey | undefined {
  const {
    coord: { y },
  } = state;

  if (y == 10) return  {
    voxelTypeNamespace: TENET_NAMESPACE,
    voxelTypeId: keccak256("grass"),
    voxelVariantNamespace: TENET_NAMESPACE,
    voxelVariantId: keccak256("grass")
  };
}

export function Dirt(state: TerrainState): VoxelTypeDataKey | undefined {
  const {
    coord: { y },
  } = state;

  if (y > -63 && y < 10) return {
    voxelTypeNamespace: TENET_NAMESPACE,
    voxelTypeId: keccak256("dirt"),
    voxelVariantNamespace: TENET_NAMESPACE,
    voxelVariantId: keccak256("dirt")
  };
}
