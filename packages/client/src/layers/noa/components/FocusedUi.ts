import { Type, World, defineComponent } from "@latticexyz/recs";

export enum FocusedUiType {
  TENET_SIDEBAR = "tenet_sidebar",
  INVENTORY = "inventory",
  WORLD = "world",
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
