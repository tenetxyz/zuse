import { Entity, Type, World, defineComponent } from "@latticexyz/recs";

// This is the spawn the user have selected they are going to classify
export function defineSpawnToClassifyComponent(world: World) {
  return defineComponent(
    world,
    {
      spawn: Type.OptionalT,
      creation: Type.OptionalT,
    },
    { id: "SpawnToClassify" }
  );
}
