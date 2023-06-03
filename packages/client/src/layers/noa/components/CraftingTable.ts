import { defineComponent, Type, World } from "@latticexyz/recs";

export function defineCraftingTableComponent(world: World) {
  return defineComponent(world, { value: Type.EntityArray }, { id: "CraftingTable" });
}
