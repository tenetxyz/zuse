import { Type, World, defineComponent } from "@latticexyz/recs";

export enum FocusedUiType {
  SIDEBAR_VOXEL_TYPE_STORE = "sidebar_voxel_type_store",
  SIDEBAR_REGISTER_CREATION = "sidebar_register_creation",
  SIDEBAR_CREATION_STORE = "sidebar_creation_store",
  SIDEBAR_CLASSIFY_STORE = "sidebar_classify_store",
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
