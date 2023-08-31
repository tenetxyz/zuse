import { defineComponent, Type, World } from "@latticexyz/recs";

export function defineComponentsRegistryComponent(world: World) {
  return defineComponent(
    world,
    { value: Type.String },
    {
      id: "ComponentsRegistry",
      metadata: { contractId: "world.component.components" },
    }
  );
}
