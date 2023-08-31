import { defineComponent, Type, World } from "@latticexyz/recs";

export function defineNameComponent(world: World) {
  return defineComponent(
    world,
    { value: Type.String },
    {
      id: "Name",
      metadata: { contractId: "component.Name" },
    }
  );
}
