import { World } from "@latticexyz/recs";
import { defineNumberComponent } from "@latticexyz/std-client";

export function defineWorldScaleComponent(world: World) {
  return defineNumberComponent(world, { id: "WorldScale" });
}
