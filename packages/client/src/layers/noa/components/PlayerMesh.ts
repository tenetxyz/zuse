import { defineComponent, Type, World } from "@latticexyz/recs";

export function definePlayerMeshComponent(world: World) {
  return defineComponent(world, { value: Type.Boolean }, { id: "PlayerMesh" });
}
