import { Type, World } from "@latticexyz/recs";
import { defineStringComponent } from "@latticexyz/std-client";

// This is the spawnId the user is looking at
export function defineSpawnInFocusComponent(world: World) {
  return defineStringComponent(world, { id: "SpawnInFocus" });
}
