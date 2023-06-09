import { World } from "@latticexyz/recs";
import { defineStringComponent } from "@latticexyz/std-client";

export function defineVoxelTypeComponent(world: World) {
  return defineStringComponent(world, {
    id: "VoxelType",
    metadata: { contractId: "component.VoxelType" },
  });
}
