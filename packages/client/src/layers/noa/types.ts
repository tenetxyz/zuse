import { Entity } from "@latticexyz/recs";
import { createNoaLayer } from "./createNoaLayer";

export type NoaLayer = Awaited<ReturnType<typeof createNoaLayer>>;

export type Material = {
  color?: [number, number, number];
  textureUrl?: string;
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
  material:
    | string
    | [string, string]
    | [string, string, string]
    | [string, string, string, string, string, string];
  type: NoaBlockType;
  frames?: number;
  opaque?: boolean;
  fluid?: boolean;
  solid?: boolean;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  blockMesh?: any; // this MUST be called blockMesh (not voxelMesh) since it's used by noa
  uvWrap?: string | undefined;
};

export type VoxelTypeDataKey = {
  voxelTypeNamespace: string;
  voxelTypeId: string;
  voxelVariantNamespace: string;
  voxelVariantId: string;
}

export type VoxelVariantDataKey = {
  voxelVariantNamespace: string;
  voxelVariantId: string;
}

export type VoxelVariantDataValue = {
  index: number;
  data: NoaVoxelDef | undefined;
}

export type VoxelVariantData = Map<string, VoxelVariantDataValue>;

export function voxelVariantDataKeyToString(key: VoxelVariantDataKey) {
  return `${key.voxelVariantNamespace}:${key.voxelVariantId}`;
}

export function voxelVariantKeyStringToKey(key: string): VoxelVariantDataKey {
  const [voxelVariantNamespace, voxelVariantId] = key.split(":");
  return {
    voxelVariantNamespace,
    voxelVariantId,
  };
}

export function voxelTypeToEntity(voxelType: VoxelTypeDataKey): Entity {
  return (voxelType.voxelTypeNamespace + "-" + voxelType.voxelTypeId + "-" + voxelType.voxelVariantNamespace + "-" + voxelType.voxelVariantId) as Entity;
}

export function entityToVoxelType(entity: Entity): VoxelTypeDataKey {
  const [voxelTypeNamespace, voxelTypeId, voxelVariantNamespace, voxelVariantId] = entity.split("-");
  return { voxelTypeNamespace, voxelTypeId, voxelVariantNamespace, voxelVariantId };
}

export function voxelTypeDataKeyToVoxelVariantDataKey(key: VoxelTypeDataKey): VoxelVariantDataKey {
  return {
    voxelVariantNamespace: key.voxelVariantNamespace,
    voxelVariantId: key.voxelVariantId,
  };
}