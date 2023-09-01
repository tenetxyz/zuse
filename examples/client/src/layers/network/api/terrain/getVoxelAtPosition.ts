import { Component, Entity, getComponentValue, getEntitiesWithValue, Type, World } from "@latticexyz/recs";
import { VoxelCoord } from "@latticexyz/utils";
import { Perlin } from "@latticexyz/noise";
import { Terrain, TerrainState } from "./types";
import { getTerrain } from "./utils";
import { Air, AIR_ID, Bedrock, Dirt, Tile } from "./occurrence";
import { parseTwoKeysFromMultiKeyString, VoxelTypeKey, VoxelTypeKeyInMudTable } from "@/layers/noa/types";
import { to64CharAddress } from "../../../../utils/entity";

export function getEntityAtPosition(
  context: {
    Position: Component<{ x: Type.Number; y: Type.Number; z: Type.Number }>;
    VoxelType: Component<{
      voxelTypeId: Type.String;
      voxelVariantId: Type.String;
    }>;
    world: World;
  },
  coord: VoxelCoord,
  scale: number
): Entity | undefined {
  const { Position, VoxelType } = context;
  const currentScaleInHexadecimal = to64CharAddress("0x" + scale);
  const entityKeysAtPosition = [...getEntitiesWithValue(Position, coord)].filter((entityKey) => {
    // filter out the voxels that are not at the current scale
    const [scaleInHexadecimal, _entity] = parseTwoKeysFromMultiKeyString(entityKey);
    return scaleInHexadecimal === currentScaleInHexadecimal;
  });

  // Prefer non-air voxels at this position
  return (
    entityKeysAtPosition?.find((entityKey) => {
      const voxelType = getComponentValue(VoxelType, entityKey);
      return voxelType && voxelType.voxelTypeId !== AIR_ID;
    }) ?? entityKeysAtPosition[0]
  );
}

export function getEcsVoxelType(
  context: {
    Position: Component<{ x: Type.Number; y: Type.Number; z: Type.Number }>;
    VoxelType: Component<{
      voxelTypeId: Type.String;
      voxelVariantId: Type.String;
    }>;
    world: World;
  },
  coord: VoxelCoord,
  scale: number
): VoxelTypeKey | undefined {
  const { VoxelType } = context;
  const entityKeyAtPosition = getEntityAtPosition(context, coord, scale);
  if (!entityKeyAtPosition) return undefined;
  // getEntityAtPosition already filters for voxels at the current scale, so we don't need to check it again here
  const voxelTypeKeyInMudTable = getComponentValue(VoxelType, entityKeyAtPosition) as VoxelTypeKeyInMudTable;

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
  },
  perlin: Perlin,
  coord: VoxelCoord,
  scale: number
): VoxelTypeKey {
  return getEcsVoxelType(context, coord, scale) ?? getTerrainVoxel(getTerrain(coord, perlin), coord, perlin, scale);
}

export function getTerrainVoxel(
  { biome: biomeVector, height }: Terrain,
  coord: VoxelCoord,
  perlin: Perlin,
  scale: number
): VoxelTypeKey {
  const state: TerrainState = { biomeVector, height, coord, perlin, scale };
  return (
    Bedrock(state) ||
    Air(state) ||
    Tile(state) ||
    Dirt(state) || {
      voxelBaseTypeId: AIR_ID,
      voxelVariantTypeId: AIR_ID,
    }
  );
}
