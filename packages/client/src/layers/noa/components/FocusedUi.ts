import { Type, World, defineComponent } from "@latticexyz/recs";

export enum FocusedUiType {
  SIDEBAR = "Sidebar",
  INVENTORY = "Inventory",
  WORLD = "World",
}

export function defineFocusedUiComponent(world: World) {
  return defineComponent(
    world,
    {
      value: Type.T,
    },
    { id: "FocusedUi" }
  );
}
