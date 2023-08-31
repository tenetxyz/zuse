import { VoxelEntity } from "@/layers/noa/types";
import { ComponentUpdate, Entity, Schema } from "@latticexyz/recs";
import { VoxelCoord } from "@latticexyz/utils";
import { WorldMetadata } from "./componentParser";
import { abiDecode } from "@/utils/encodeOrDecode";
import { decodeCoord } from "@/utils/coord";

export interface ISpawn {
  spawnId: Entity;
  isModified: boolean;
  creationId: Entity;
  lowerSouthWestCorner: VoxelCoord;
  voxels: VoxelEntity[]; // the voxelIds that have been spawned
}

export function parseSpawn<S extends Schema>(update: ComponentUpdate<S, undefined>, worldMetadata: WorldMetadata) {
  const spawnId = update.entity;
  const rawSpawn = update.value[0];
  if (rawSpawn === undefined) {
    return undefined;
  }

  const voxels = abiDecode("(uint32 scale,bytes32 entityId)[]", rawSpawn.voxels as string);
  const spawn = {
    spawnId: spawnId,
    creationId: rawSpawn.creationId,
    isModified: rawSpawn.isModified,
    lowerSouthWestCorner: decodeCoord(rawSpawn.lowerSouthWestCorner as string),
    voxels: voxels,
  } as ISpawn;
  return { entityId: spawnId, componentRecord: spawn };
}
