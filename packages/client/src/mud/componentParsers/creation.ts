import { BaseCreation } from "@/layers/noa/systems/createSpawnOverlaySystem";
import { VoxelTypeKey, VoxelTypeKeyInMudTable } from "@/layers/noa/types";
import { parseCreationMetadata } from "@/utils/useCreationSearch";
import { ComponentUpdate, Entity, Schema } from "@latticexyz/recs";
import { VoxelCoord } from "@latticexyz/utils";
import { WorldMetadata } from "./componentParser";
import { abiDecode, decodeBaseCreations } from "@/utils/encodeOrDecode";

export interface Creation {
  name: string;
  description: string;
  creationId: Entity;
  creator: string;
  voxelTypes: VoxelTypeKey[];
  relativePositions: VoxelCoord[];
  numSpawns: number;
  numVoxels: number;
  // voxelMetadata: string[];
  baseCreations: BaseCreation[];
}

export function parseCreation<S extends Schema>(update: ComponentUpdate<S, undefined>, worldMetadata: WorldMetadata) {
  const creationId = update.entity;
  const rawCreation = update.value[0];
  if (rawCreation === undefined) {
    return undefined;
  }
  const { creator, name, description, numSpawns } = parseCreationMetadata(
    rawCreation.metadata as string,
    worldMetadata.worldAddress
  );
  if (!creator) {
    console.warn("No creator found for creation", creationId);
    return undefined;
  }
  const rawVoxelTypes = rawCreation.voxelTypes as string;
  const voxelTypes: VoxelTypeKey[] = (
    abiDecode("tuple(bytes32 voxelTypeId,bytes32 voxelVariantId)[]", rawVoxelTypes) as VoxelTypeKeyInMudTable[]
  ).map((voxelKey) => {
    return {
      voxelBaseTypeId: voxelKey.voxelTypeId,
      voxelVariantTypeId: voxelKey.voxelVariantId,
    };
  });
  const encodedRelativePositions = rawCreation.relativePositions as string;
  const relativePositions =
    (abiDecode("tuple(int32 x,int32 y,int32 z)[]", encodedRelativePositions) as VoxelCoord[]) || [];
  const rawBaseCreations = rawCreation.baseCreations as string;
  const baseCreations = rawBaseCreations ? decodeBaseCreations(rawBaseCreations) : [];
  if (relativePositions.length === 0 && baseCreations.length === 0) {
    console.warn(
      `No relativePositions and no base creations found for creationId=${creationId.toString()} (name=${name} creator=${creator}). This means that this creation has no voxels`
    );
    return;
  }
  // TODO: add voxelMetadata
  const creation = {
    creationId: creationId,
    name: name,
    description: description,
    creator: creator,
    voxelTypes: voxelTypes,
    relativePositions,
    numSpawns: numSpawns,
    numVoxels: rawCreation.numVoxels,
    baseCreations,
  } as Creation;
  return { entityId: creationId, componentRecord: creation };
}
