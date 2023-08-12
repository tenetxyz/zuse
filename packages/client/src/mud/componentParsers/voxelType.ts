import { parseCreationMetadata } from "@/utils/useCreationSearch";
import { ComponentUpdate, Entity, Schema } from "@latticexyz/recs";
import { WorldMetadata } from "./componentParser";

export interface VoxelTypeDesc {
  name: string;
  description: string;
  voxelBaseTypeId: Entity; // This is the Id for this VoxelType. We call it voxelBaseType to disambiguate from the VoxelTypeKey which is a combination of voxelBaseType and voxelVariantType
  baseVoxelTypeId: Entity; // the base voxel type that this voxel type inherits
  previewVoxelVariantId: string;
  numSpawns: number;
  creator: string;
  scale: number;
  childVoxelTypeIds: string[];
}

export function parseVoxelType<S extends Schema>(update: ComponentUpdate<S, undefined>, worldMetadata: WorldMetadata) {
  const voxelTypeId = update.entity;
  const rawVoxelType = update.value[0];
  if (rawVoxelType === undefined) {
    return undefined;
  }

  const { creator, name, description, numSpawns } = parseCreationMetadata(
    rawVoxelType.metadata as string,
    worldMetadata.worldAddress
  );

  const voxelTypeDesc = {
    name,
    description,
    voxelBaseTypeId: voxelTypeId,
    baseVoxelTypeId: rawVoxelType.baseVoxelTypeId,
    previewVoxelVariantId: rawVoxelType.previewVoxelVariantId,
    numSpawns,
    creator,
    scale: rawVoxelType.scale,
    childVoxelTypeIds: rawVoxelType.childVoxelTypeIds,
  } as VoxelTypeDesc;
  return { entityId: voxelTypeId, componentRecord: voxelTypeDesc };
}
