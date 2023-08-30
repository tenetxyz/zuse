import { defineComponent, Type, World } from "@latticexyz/recs";

export function defineOwnedByComponent(world: World) {
  return defineComponent(
    world,
    { value: Type.String },
    {
      id: "OwnedBy",
      metadata: { contractId: "component.OwnedBy" },
    }
  );
}
