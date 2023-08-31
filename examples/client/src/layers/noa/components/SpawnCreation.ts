import { defineComponent, Type, World } from "@latticexyz/recs";
import { Creation } from "../../react/components/CreationStore";

export interface ISpawnCreation {
  creation?: Creation;
}

// This component tracks the creation that the player is trying to spawn
export function defineSpawnCreationComponent(world: World) {
  return defineComponent(
    world,
    {
      creation: Type.OptionalT,
    },
    { id: "SpawnCreationComponent" }
  );
}
