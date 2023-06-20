import { defineComponent, Type, World } from "@latticexyz/recs";
import { VoxelCoord } from "@latticexyz/utils";
import { Creation } from "../../react/components/CreationStore";

export interface ISpawnCreation {
  creation?: Creation;
}

export function defineSpawnCreationComponent(world: World) {
  return defineComponent(
    world,
    {
      creation: Type.OptionalT,
    },
    { id: "SpawnCreationComponent" }
  );
}
