import { Entity } from "@latticexyz/recs";
import { createNoaLayer } from "./createNoaLayer";

export type NoaLayer = Awaited<ReturnType<typeof createNoaLayer>>;

export type Material = {
  color?: [number, number, number];
  textureUrl?: string;
};

export type InterfaceVoxel = {
  index: number;
  entity: VoxelEntity;
  name: string;
  desc: string;
};

export type VoxelEntity = {
  scale: number;
  entityId: string;
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

export type VoxelBaseTypeId = string; // TODO: make this an entity?
export type VoxelVariantTypeId = string;

export type VoxelTypeKeyInMudTable = {
  voxelTypeId: VoxelBaseTypeId;
  voxelVariantId: VoxelVariantTypeId;
};

export type VoxelTypeKey = {
  voxelBaseTypeId: VoxelBaseTypeId;
  voxelVariantTypeId: VoxelVariantTypeId;
};

export type VoxelVariantNoaDef = {
  noaBlockIdx: number; // this is the idx of this variant in NOA. I think there will be a bug when we have 255 entities in the game, since noa can't assign blocks new entities
  noaVoxelDef: NoaVoxelDef | undefined;
};

export type VoxelVariantIdToDefMap = Map<VoxelVariantTypeId, VoxelVariantNoaDef>;

export function voxelTypeToEntity(voxelTypeKey: VoxelTypeKeyInMudTable): Entity {
  return `${voxelTypeKey.voxelTypeId}:${voxelTypeKey.voxelVariantId}` as Entity;
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
export const EMPTY_VOXEL_ENTITY: VoxelEntity = {
  scale: 0,
  entityId: EMPTY_BYTES_32,
};
export const voxelEntityIsEmptyVoxel = (voxelEntity: VoxelEntity): boolean => {
  return voxelEntity.scale === EMPTY_VOXEL_ENTITY.scale && voxelEntity.entityId === EMPTY_VOXEL_ENTITY.entityId;
};
