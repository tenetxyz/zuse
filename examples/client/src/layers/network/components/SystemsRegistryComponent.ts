import { defineComponent, Type, World } from "@latticexyz/recs";

export function defineSystemsRegistryComponent(world: World) {
  return defineComponent(
    world,
    { value: Type.String },
    {
      id: "SystemsRegistry",
      metadata: { contractId: "world.component.systems" },
    }
  );
}
