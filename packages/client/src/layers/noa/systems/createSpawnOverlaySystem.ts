// the purpose of this system is to render a wireframe around voxels/creations the user selects

import { NetworkLayer } from "../../network";
import { NoaLayer } from "../types";
import { renderChunkyWireframe } from "./renderWireframes";
import { Color3, Mesh } from "@babylonjs/core";
import { add, calculateMinMaxRelativeCoordsOfCreation, decodeCoord, getWorldScale } from "../../../utils/coord";
import { Entity } from "@latticexyz/recs";
import { VoxelCoord } from "@latticexyz/utils";

export type BaseCreation = {
  creationId: Entity;
  coordOffset: VoxelCoord; // the offset of the base creation relative to the creation this base creation is in
  deletedRelativeCoords: VoxelCoord[]; // the coord relative to this BASE creation, not to the creation this base creation is in
};

// All creations that are spawned will have an overlay around them
// This is so when people modify a spawned creation, they know they are modifying that spawn instance
export function createSpawnOverlaySystem(networkLayer: NetworkLayer, noaLayer: NoaLayer) {
  const { noa } = noaLayer;
  const {
    parsedComponents: { ParsedVoxelTypeRegistry, ParsedCreationRegistry, ParsedSpawn },
    world,
  } = networkLayer;

  const subscription = ParsedSpawn.updateStream$.subscribe((spawn) => {
    // When a spawn has been deleted/created, re-render the spawn outlines
    renderSpawnOutlines();
  });
  world.registerDisposer(() => subscription.unsubscribe());

  // when the player zooms to a different level, we need to re-render the spawn outlines (since voxels on a spawn may not exist on that level)
  noa.on("newWorldName", (_newWorldName: string) => {
    renderSpawnOutlines();
  });

  let spawnOutlineMeshes: Mesh[] = [];
  const renderSpawnOutlines = () => {
    // PERF: only dispose of the meshes that changed
    for (let i = 0; i < spawnOutlineMeshes.length; i++) {
      spawnOutlineMeshes[i].dispose();
    }
    spawnOutlineMeshes = [];
    const scale = getWorldScale(noa);

    const spawns = ParsedSpawn.componentRows.values();
    for (const spawn of spawns) {
      const { minCoord, maxCoord } = calculateMinMaxRelativeCoordsOfCreation(
        ParsedVoxelTypeRegistry,
        ParsedCreationRegistry,
        spawn.creationId,
        scale
      );

      const corner1 = add(spawn.lowerSouthWestCorner, minCoord);
      const corner2 = add(spawn.lowerSouthWestCorner, maxCoord);

      const mesh = renderChunkyWireframe(
        corner1,
        corner2,
        noa,
        new Color3(1, 1, 0), // yellow
        0.045
      );
      if (mesh !== null) {
        spawnOutlineMeshes.push(mesh);
      }
    }
  };
}
