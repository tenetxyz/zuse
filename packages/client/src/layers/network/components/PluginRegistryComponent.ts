import { defineComponent, Type, World } from "@latticexyz/recs";

export function definePluginRegistryComponent(world: World) {
  return defineComponent(
    world,
    { value: Type.String },
    {
      id: "PluginRegistry",
      metadata: { contractId: "component.PluginRegistry" },
    }
  );
}
