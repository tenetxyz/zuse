import { defineComponent, Type, World } from "@latticexyz/recs";

export function defineStakeComponent(world: World) {
  return defineComponent(
    world,
    { value: Type.Number },
    {
      id: "Stake",
      metadata: { contractId: "component.Stake" },
    }
  );
}
