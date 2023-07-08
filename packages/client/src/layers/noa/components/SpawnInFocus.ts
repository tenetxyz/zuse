import { Entity, Type, World, defineComponent } from "@latticexyz/recs";
import { VoxelCoord } from "@latticexyz/utils";

export interface ISpawn {
  spawnId: Entity;
  creationId: Entity;
  lowerSouthWestCorner: VoxelCoord;
  voxels: Entity[]; // the voxelIds that have been spawned
}

// This is the spawn the user is looking at
export function defineSpawnInFocusComponent(world: World) {
  return defineComponent(
    world,
    {
      spawn: Type.OptionalT,
      creation: Type.OptionalT, // the creation that the spawn is an instance of
    },
    { id: "SpawnInFocus" }
  );
}
