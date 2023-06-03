import { defineComponent, Type, World } from "@latticexyz/recs";

// maps blockId -> the inventory index it's in
export function defineInventoryIndexComponent(world: World) {
  return defineComponent(world, { value: Type.Number }, { id: "InventoryIndex" });
}
