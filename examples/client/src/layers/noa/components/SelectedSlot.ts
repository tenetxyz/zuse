import { defineComponent, Type, World } from "@latticexyz/recs";

export function defineSelectedSlotComponent(world: World) {
  return defineComponent(world, { value: Type.Number }, { id: "SelectedSlot" });
}
