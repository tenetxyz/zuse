import { defineComponent, Type, World } from "@latticexyz/recs";

export function defineWorldScaleComponent(world: World) {
  return defineComponent(world, { value: Type.Number }, { id: "WorldScale" });
}
