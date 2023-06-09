import {
  Component,
  Entity,
  getComponentValue,
  getEntitiesWithValue,
  Type,
  World,
} from "@latticexyz/recs";
import { VoxelCoord } from "@latticexyz/utils";
import { Perlin } from "@latticexyz/noise";
import { VoxelTypeKeyToId } from "../../constants";
import { Terrain, TerrainState } from "./types";
import { getTerrain } from "./utils";
import { Air, Bedrock, Dirt, Grass } from "./occurrence";

export function getEntityAtPosition(
  context: {
    Position: Component<{ x: Type.Number; y: Type.Number; z: Type.Number }>;
    VoxelType: Component<{ value: Type.String }>;
    world: World;
  },
  coord: VoxelCoord
): Entity | undefined {
  const { Position, VoxelType } = context;
  const entitiesAtPosition = [...getEntitiesWithValue(Position, coord)];

  // Prefer non-air blocks at this position
  return (
    entitiesAtPosition?.find((b) => {
      const voxelType = getComponentValue(VoxelType, b);
      return voxelType && voxelType.value !== VoxelTypeKeyToId.Air;
    }) ?? entitiesAtPosition[0]
  );
}

export function getEcsVoxel(
  context: {
    Position: Component<{ x: Type.Number; y: Type.Number; z: Type.Number }>;
    VoxelType: Component<{ value: Type.String }>;
    world: World;
  },
  coord: VoxelCoord
): Entity | undefined {
  const entityAtPosition = getEntityAtPosition(context, coord);
  if (!entityAtPosition) return undefined;
  return getComponentValue(context.VoxelType, entityAtPosition)
    ?.value as Entity;
}

export function getVoxelAtPosition(
  context: {
    Position: Component<{ x: Type.Number; y: Type.Number; z: Type.Number }>;
    VoxelType: Component<{ value: Type.String }>;
    world: World;
  },
  perlin: Perlin,
  coord: VoxelCoord
): Entity {
  return (
    getEcsVoxel(context, coord) ??
    getTerrainVoxel(getTerrain(coord, perlin), coord, perlin)
  );
}

export function getTerrainVoxel(
  { biome: biomeVector, height }: Terrain,
  coord: VoxelCoord,
  perlin: Perlin
): Entity {
  const state: TerrainState = { biomeVector, height, coord, perlin };
  return (
    Bedrock(state) ||
    Air(state) ||
    Grass(state) ||
    Dirt(state) ||
    VoxelTypeKeyToId.Air
  );
}
