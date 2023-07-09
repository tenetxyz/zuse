import { defineComponent, Type, World } from "@latticexyz/recs";

export function defineUIComponent(world: World) {
  // PERF: this is a HUGE timesave if we just separate this UI component into 4 diff components
  // since everytime we open any of these UIs, we rerender ALL the other UIs (since they're all in the object)
  return defineComponent(
    world,
    {
      showAdminPanel: Type.Boolean,
      showCrafting: Type.Boolean,
      showPlugins: Type.Boolean,
    },
    { id: "UI" }
  );
}
