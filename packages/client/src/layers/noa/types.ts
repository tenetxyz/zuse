import { ComponentValue, Type } from "@latticexyz/recs";
import { Entity } from "@latticexyz/recs";
import { createNoaLayer } from "./createNoaLayer";

export type NoaLayer = Awaited<ReturnType<typeof createNoaLayer>>;

export type Material = {
  color?: [number, number, number];
  textureUrl?: string;
};

export type InterfaceVoxel = {
  index: number;
  entity: string;
  name: string;
  desc: string;
};

export enum NoaBlockType {
  BLOCK,
  MESH,
}

/*
 * material: can be:
 * one (String) material name
 * array of 2 names: [top/bottom, sides]
 * array of 3 names: [top, bottom, sides]
 * array of 6 names: [-x, +x, -y, +y, -z, +z]
 */
export type NoaVoxelDef = {
  material: string | [string, string] | [string, string, string] | [string, string, string, string, string, string];
  type: NoaBlockType;
  frames?: number;
  opaque?: boolean;
  fluid?: boolean;
  solid?: boolean;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  blockMesh?: any; // this MUST be called blockMesh (not voxelMesh) since it's used by noa
  uvWrap?: string | undefined;
};

export type VoxelBaseTypeId = string;
export type VoxelVariantTypeId = string;

export type VoxelTypeKey = {
  voxelBaseTypeId: VoxelBaseTypeId;
  voxelVariantTypeId: VoxelVariantTypeId;
};

export type VoxelVariantDataValue = {
  index: number;
  data: NoaVoxelDef | undefined;
};

export type VoxelVariantData = Map<VoxelVariantTypeId, VoxelVariantDataValue>;

export function voxelTypeToEntity(voxelType: VoxelTypeKey): Entity {
  return `${voxelType.voxelBaseTypeId}:${voxelType.voxelVariantTypeId}` as Entity;
}

export function entityToVoxelType(entity: Entity): VoxelTypeKey {
  const [voxelBaseTypeId, voxelVariantTypeId] = entity.split(":");
  return { voxelBaseTypeId, voxelVariantTypeId };
}

export function voxelBaseTypeIdToVoxelTypeKey(voxelBaseTypeId: VoxelBaseTypeId): VoxelTypeKey {
  return {
    voxelBaseTypeId: voxelBaseTypeId,
    voxelVariantTypeId: EMPTY_BYTES_32,
  };
}

export const EMPTY_BYTES_32 = "0x0000000000000000000000000000000000000000000000000000000000000000";
