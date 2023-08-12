import { parseCreationMetadata } from "@/utils/useCreationSearch";
import { ComponentUpdate, Entity, Schema } from "@latticexyz/recs";
import { WorldMetadata } from "./componentParser";

export interface VoxelTypeDesc {
  name: string;
  description: string;
  voxelBaseTypeId: Entity;
  previewVoxelVariantId: string;
  numSpawns: number;
  creator: string;
  scale: number;
  childVoxelTypeIds: string[];
}

export function parseVoxelType<S extends Schema>(update: ComponentUpdate<S, undefined>, worldMetadata: WorldMetadata) {
  const voxelTypeId = update.entity; // same as voxelBaseTypeId
  const rawVoxelType = update.value[0];
  if (rawVoxelType === undefined) {
    return undefined;
  }

  const { creator, name, description, numSpawns } = parseCreationMetadata(
    rawVoxelType.metadata as string,
    worldMetadata.worldAddress
  );

  // TODO: add voxelMetadata
  const voxelTypeDesc = {
    name,
    description,
    voxelBaseTypeId: rawVoxelType.baseVoxelTypeId,
    previewVoxelVariantId: rawVoxelType.previewVoxelVariantId,
    numSpawns,
    creator,
    scale: rawVoxelType.scale,
    childVoxelTypeIds: rawVoxelType.childVoxelTypeIds,
  } as VoxelTypeDesc;
  return { entityId: voxelTypeId, componentRecord: voxelTypeDesc };
}
