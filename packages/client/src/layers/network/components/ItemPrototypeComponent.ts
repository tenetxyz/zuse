import { World } from "@latticexyz/recs";
import { defineBoolComponent } from "@latticexyz/std-client";

export function defineVoxelTypePrototypeComponent(world: World) {
  return defineBoolComponent(world, {
    id: "VoxelTypePrototype",
    metadata: { contractId: "component.VoxelTypePrototype" },
  });
}
