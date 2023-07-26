import { Component, Entity, getComponentValue, getEntitiesWithValue, Type, World } from "@latticexyz/recs";
import { VoxelCoord } from "@latticexyz/utils";
import { Perlin } from "@latticexyz/noise";
import { Terrain, TerrainState } from "./types";
import { getTerrain } from "./utils";
import { Air, AIR_ID, Bedrock, Dirt, Grass } from "./occurrence";
import { VoxelTypeKey, VoxelTypeKeyInMudTable } from "@tenetxyz/layers/noa/types";
import { TenetStoreCache } from "@tenetxyz/mud/setupNetwork";
import { LiveStoreCache } from "@tenetxyz/mud/setupLiveStoreCache";

export function getEntityAtPosition(
  context: {
    Position: Component<{ x: Type.Number; y: Type.Number; z: Type.Number }>;
    VoxelType: Component<{
      voxelTypeId: Type.String;
      voxelVariantId: Type.String;
    }>;
    world: World;
    liveStoreCache: LiveStoreCache;
  },
  coord: VoxelCoord,
  scale: number
): Entity | undefined {
  const { Position, liveStoreCache } = context;
  const entitiesAtPosition = [...getEntitiesWithValue(Position, coord)];

  // Prefer non-air voxels at this position
  return (
    entitiesAtPosition?.find((entity) => {
      const voxelType = liveStoreCache.VoxelType.get({ entity: entity, scale: scale });
      return voxelType && voxelType.voxelTypeId !== AIR_ID;
    }) ?? entitiesAtPosition[0]
  );
}

export function getEcsVoxelType(
  context: {
    Position: Component<{ x: Type.Number; y: Type.Number; z: Type.Number }>;
    VoxelType: Component<{
      voxelTypeId: Type.String;
      voxelVariantId: Type.String;
    }>;
    liveStoreCache: LiveStoreCache;
    world: World;
  },
  coord: VoxelCoord,
  scale: number
): VoxelTypeKey | undefined {
  const { liveStoreCache } = context;
  const entityAtPosition = getEntityAtPosition(context, coord, scale);
  if (!entityAtPosition) return undefined;
  const voxelTypeKeyInMudTable = liveStoreCache.VoxelType.get({
    entity: entityAtPosition,
    scale: scale,
  }) as VoxelTypeKeyInMudTable;
  return {
    voxelBaseTypeId: voxelTypeKeyInMudTable.voxelTypeId,
    voxelVariantTypeId: voxelTypeKeyInMudTable.voxelVariantId,
  };
}

export function getVoxelAtPosition(
  context: {
    Position: Component<{ x: Type.Number; y: Type.Number; z: Type.Number }>;
    VoxelType: Component<{
      voxelTypeId: Type.String;
      voxelVariantId: Type.String;
    }>;
    world: World;
    liveStoreCache: LiveStoreCache;
  },
  perlin: Perlin,
  coord: VoxelCoord,
  scale: number
): VoxelTypeKey {
  return getEcsVoxelType(context, coord, scale) ?? getTerrainVoxel(getTerrain(coord, perlin), coord, perlin);
}

export function getTerrainVoxel(
  { biome: biomeVector, height }: Terrain,
  coord: VoxelCoord,
  perlin: Perlin
): VoxelTypeKey {
  const state: TerrainState = { biomeVector, height, coord, perlin };
  return (
    Bedrock(state) ||
    Air(state) ||
    Grass(state) ||
    Dirt(state) || {
      voxelBaseTypeId: AIR_ID,
      voxelVariantTypeId: AIR_ID,
    }
  );
}
