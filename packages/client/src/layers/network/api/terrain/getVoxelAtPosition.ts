import {
  Component,
  Entity,
  getComponentValue,
  getEntitiesWithValue,
  Type,
  World,
} from "@latticexyz/recs";
import { VoxelCoord, keccak256 } from "@latticexyz/utils";
import { Perlin } from "@latticexyz/noise";
import { Terrain, TerrainState } from "./types";
import { getTerrain } from "./utils";
import { Air, Bedrock, Dirt, Grass } from "./occurrence";
import { VoxelTypeDataKey } from "../../../noa/types";

export function getEntityAtPosition(
  context: {
    Position: Component<{ x: Type.Number; y: Type.Number; z: Type.Number }>;
    VoxelType: Component<{
      namespace: Type.String;
      voxelType: Type.String;
      voxelVariantNamespace: Type.String;
      voxelVariantId: Type.String;
  }>;
    world: World;
  },
  coord: VoxelCoord
): Entity | undefined {
  const { Position, VoxelType } = context;
  const entitiesAtPosition = [...getEntitiesWithValue(Position, coord)];

  // Prefer non-air voxels at this position
  return (
    entitiesAtPosition?.find((b) => {
      const voxelType = getComponentValue(VoxelType, b);
      return voxelType;
    }) ?? entitiesAtPosition[0]
  );
}

export function getEcsVoxelType(
  context: {
    Position: Component<{ x: Type.Number; y: Type.Number; z: Type.Number }>;
    VoxelType: Component<{
      namespace: Type.String;
      voxelType: Type.String;
      voxelVariantNamespace: Type.String;
      voxelVariantId: Type.String;
  }>;
    world: World;
  },
  coord: VoxelCoord
): VoxelTypeDataKey | undefined {
  const entityAtPosition = getEntityAtPosition(context, coord);
  if (!entityAtPosition) return undefined;
  const voxelTypeData = getComponentValue(context.VoxelType, entityAtPosition);
  if (!voxelTypeData) return undefined;
  return {
    namespace: voxelTypeData.voxelVariantNamespace,
    voxelVariantId: voxelTypeData.voxelVariantId,
  };
}

export function getVoxelAtPosition(
  context: {
    Position: Component<{ x: Type.Number; y: Type.Number; z: Type.Number }>;
    VoxelType: Component<{
      namespace: Type.String;
      voxelType: Type.String;
      voxelVariantNamespace: Type.String;
      voxelVariantId: Type.String;
  }>;
    world: World;
  },
  perlin: Perlin,
  coord: VoxelCoord
): VoxelTypeDataKey {
  return (
    getEcsVoxelType(context, coord) ??
    getTerrainVoxel(getTerrain(coord, perlin), coord, perlin)
  );
}

export function getTerrainVoxel(
  { biome: biomeVector, height }: Terrain,
  coord: VoxelCoord,
  perlin: Perlin
): VoxelTypeDataKey {
  const state: TerrainState = { biomeVector, height, coord, perlin };
  return (
    Bedrock(state) ||
    Air(state) ||
    Grass(state) ||
    Dirt(state) ||
    {
      namespace: "tenet",
      voxelVariantId: keccak256("air")
    }
  );
}
