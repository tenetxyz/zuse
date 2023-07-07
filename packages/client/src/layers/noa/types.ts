import { ComponentValue, Type } from "@latticexyz/recs";
import { Entity } from "@latticexyz/recs";
import { createNoaLayer } from "./createNoaLayer";
import { VoxelCoord } from "@latticexyz/utils";

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

export type VoxelTypeRegistryData = ComponentValue<{
  voxelVariantSelector: Type.String;
  creator: Type.String;
  numSpawns: Type.BigInt;
  name: Type.String;
  preview: Type.String;
  previewUVWrap: Type.String;
}>;

export type VoxelTypeDataKey = {
  voxelTypeNamespace: string;
  voxelTypeId: string;
  voxelVariantNamespace: string;
  voxelVariantId: string;
};

export type VoxelTypeBaseKey = {
  voxelTypeNamespace: string;
  voxelTypeId: string;
};

export type VoxelVariantDataKey = {
  voxelVariantNamespace: string;
  voxelVariantId: string;
};

export type VoxelVariantDataValue = {
  index: number;
  data: NoaVoxelDef | undefined;
};

export type VoxelVariantData = Map<string, VoxelVariantDataValue>;

export function voxelTypeDataKeyToVoxelVariantDataKey(key: VoxelTypeDataKey): VoxelVariantDataKey {
  return {
    voxelVariantNamespace: key.voxelVariantNamespace,
    voxelVariantId: key.voxelVariantId,
  };
}

export function voxelVariantDataKeyToString(key: VoxelVariantDataKey): string {
  return `${key.voxelVariantNamespace}:${key.voxelVariantId}`;
}

export function voxelVariantKeyStringToKey(key: string): VoxelVariantDataKey {
  const [voxelVariantNamespace, voxelVariantId] = key.split(":");
  return {
    voxelVariantNamespace,
    voxelVariantId,
  };
}

export function voxelTypeToVoxelTypeBaseDataKey(voxelType: VoxelTypeDataKey): VoxelTypeBaseKey {
  return {
    voxelTypeNamespace: voxelType.voxelTypeNamespace,
    voxelTypeId: voxelType.voxelTypeId,
  };
}

export function voxelTypeToVoxelTypeBaseKeyString(voxelType: VoxelTypeDataKey): string {
  return `${voxelType.voxelTypeNamespace}:${voxelType.voxelTypeId}`;
}

export function voxelTypeBaseKeyToEntity(voxelTypeBaseKey: VoxelTypeBaseKey): Entity {
  return `${voxelTypeBaseKey.voxelTypeNamespace}:${voxelTypeBaseKey.voxelTypeId}` as Entity;
}

export function voxelTypeBaseKeyToTruncStr(voxelTypeBaseKey: VoxelTypeBaseKey): string {
  return `${voxelTypeBaseKey.voxelTypeNamespace.substring(0, 34)}:${voxelTypeBaseKey.voxelTypeId}`;
}

export function voxelTypeToEntity(voxelType: VoxelTypeDataKey): Entity {
  return `${voxelType.voxelTypeNamespace}:${voxelType.voxelTypeId}:${voxelType.voxelVariantNamespace}:${voxelType.voxelVariantId}` as Entity;
}

export function entityToVoxelType(entity: Entity): VoxelTypeDataKey {
  const [voxelTypeNamespace, voxelTypeId, voxelVariantNamespace, voxelVariantId] = entity.split(":");
  return { voxelTypeNamespace, voxelTypeId, voxelVariantNamespace, voxelVariantId };
}

export function entityToVoxelTypeBaseKey(entity: Entity): VoxelTypeBaseKey {
  const [voxelTypeNamespace, voxelTypeId] = entity.split(":");
  return { voxelTypeNamespace, voxelTypeId };
}

export function voxelTypeBaseKeyStrToVoxelTypeRegistryKeyStr(key: string): string {
  const [voxelTypeNamespace, voxelTypeId] = key.split(":");
  return `${voxelTypeNamespace.padEnd(66, "0")}:${voxelTypeId}`;
}

// We need to do it this sometimes because decoded coords have named keys, 0, 1, 2 in addition to x, y, z
export function cleanVoxelCoord(coord: VoxelCoord) {
  return {
    x: coord.x,
    y: coord.y,
    z: coord.z,
  };
}
