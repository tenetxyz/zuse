import { World } from "@latticexyz/recs";
import { defineBoolComponent } from "@latticexyz/std-client";

// Used to track if the player is focused on a UI screen
export function defineIsUiFocusedComponent(world: World) {
  return defineBoolComponent(world, { id: "IsUiFocused" });
}
