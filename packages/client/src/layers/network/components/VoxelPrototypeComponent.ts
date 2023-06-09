import { World } from "@latticexyz/recs";
import { defineBoolComponent } from "@latticexyz/std-client";

export function defineVoxelPrototypeComponent(world: World) {
  return defineBoolComponent(world, {
    id: "VoxelPrototype",
    metadata: { contractId: "component.VoxelPrototype" },
  });
}
