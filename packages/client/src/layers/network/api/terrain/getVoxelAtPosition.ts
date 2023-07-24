import { Component, Entity, getComponentValue, getEntitiesWithValue, Type, World } from "@latticexyz/recs";
import { VoxelCoord } from "@latticexyz/utils";
import { Perlin } from "@latticexyz/noise";
import { Terrain, TerrainState } from "./types";
import { getTerrain } from "./utils";
import { Air, AIR_ID, Bedrock, Dirt, Grass } from "./occurrence";
import { VoxelTypeDataKey } from "../../../noa/types";
import { TENET_NAMESPACE } from "../../../../constants";

export function getEntityAtPosition(
  context: {
    Position: Component<{ x: Type.Number; y: Type.Number; z: Type.Number }>;
    VoxelType: Component<{
      voxelBaseTypeId: Type.String;
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
      return voxelType && voxelType.voxelBaseTypeId !== AIR_ID;
    }) ?? entitiesAtPosition[0]
  );
}

export function getEcsVoxelType(
  context: {
    Position: Component<{ x: Type.Number; y: Type.Number; z: Type.Number }>;
    VoxelType: Component<{
      voxelBaseTypeId: Type.String;
      voxelVariantId: Type.String;
    }>;
    world: World;
  },
  coord: VoxelCoord
): VoxelTypeDataKey | undefined {
  const entityAtPosition = getEntityAtPosition(context, coord);
  if (!entityAtPosition) return undefined;
  const voxelTypeData = getComponentValue(context.VoxelType, entityAtPosition);
  return voxelTypeData;
}

export function getVoxelAtPosition(
  context: {
    Position: Component<{ x: Type.Number; y: Type.Number; z: Type.Number }>;
    VoxelType: Component<{
      voxelTypeNamespace: Type.String;
      voxelTypeId: Type.String;
      voxelVariantNamespace: Type.String;
      voxelVariantId: Type.String;
    }>;
    world: World;
  },
  perlin: Perlin,
  coord: VoxelCoord
): VoxelTypeDataKey {
  return getEcsVoxelType(context, coord) ?? getTerrainVoxel(getTerrain(coord, perlin), coord, perlin);
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
    Dirt(state) || {
      voxelTypeNamespace: TENET_NAMESPACE,
      voxelTypeId: AIR_ID,
      voxelVariantNamespace: TENET_NAMESPACE,
      voxelVariantId: AIR_ID,
    }
  );
}
