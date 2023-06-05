import { World } from "@latticexyz/recs";
import { defineNumberComponent } from "@latticexyz/std-client";

// there is only one key, the singleton key
// the value this key points to is YOUR currently selected inventory slot
export function defineSelectedSlotComponent(world: World) {
  return defineNumberComponent(world, { id: "SelectedSlot" });
}
