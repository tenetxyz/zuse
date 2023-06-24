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
  namespace: string;
  voxelVariantId: string;
}

export type VoxelTypeDataValue = {
  index: number;
  data: NoaVoxelDef | undefined;
}

export type VoxelTypeData = Map<VoxelTypeDataKey, VoxelTypeDataValue>;

export function voxelTypeDataKeyToString(key: VoxelTypeDataKey) {
  return `${key.namespace}:${key.voxelVariantId}`;
}
