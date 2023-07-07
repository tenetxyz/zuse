import { Entity, Type, World, defineComponent } from "@latticexyz/recs";
import { VoxelCoord } from "@latticexyz/utils";

export interface ISpawn {
  creationId: Entity;
  lowerSouthWestCorner: VoxelCoord;
  voxels: Entity[]; // the voxelIds that have been spawned
  interfaceVoxels: Entity[]; // the voxels that are used for i/o interfaces (e.g. for an AND gate test)
}

// This is the spawn the user is looking at
export function defineSpawnInFocusComponent(world: World) {
  return defineComponent(
    world,
    {
      spawn: Type.OptionalT,
      creation: Type.OptionalT,
    },
    { id: "SpawnInFocus" }
  );
}
