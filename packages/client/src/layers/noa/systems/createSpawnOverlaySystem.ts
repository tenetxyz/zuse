// the purpose of this system is to render a wireframe around voxels/creations the user selects

import { NetworkLayer } from "../../network";
import { NoaLayer } from "../types";
import { renderChunkyWireframe } from "./renderWireframes";
import { Color3, Mesh } from "@babylonjs/core";
import { add, calculateMinMaxRelativeCoordsOfCreation, decodeCoord } from "../../../utils/coord";
import { Entity } from "@latticexyz/recs";
import { VoxelCoord } from "@latticexyz/utils";
import { ISpawn } from "../components/SpawnInFocus";
import { abiDecode } from "@/utils/abi";

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
    contractComponents: { Spawn, Creation },
  } = networkLayer;

  Spawn.update$.subscribe((update) => {
    const spawnTable = update.component?.values;
    if (spawnTable === undefined) {
      return;
    }
    const spawns: ISpawn[] = [];
    spawnTable.creationId.forEach((creationId, rawSpawnId) => {
      const spawnId = rawSpawnId as any;
      const encodedLowerSouthWestCorner = spawnTable.lowerSouthWestCorner.get(spawnId)!;
      const lowerSouthWestCorner = decodeCoord(encodedLowerSouthWestCorner);
      const encodedVoxelEntities = spawnTable.voxels.get(spawnId)!;
      const voxelEntities = abiDecode("(uint32 scale,bytes32 entityId)[]", encodedVoxelEntities);
      if (lowerSouthWestCorner) {
        spawns.push({
          spawnId: spawnId,
          creationId: creationId as Entity,
          lowerSouthWestCorner: lowerSouthWestCorner,
          voxels: voxelEntities,
        });
      }
    });
    renderSpawnOutlines(spawns);
  });

  let spawnOutlineMeshes: Mesh[] = [];
  const renderSpawnOutlines = (spawns: ISpawn[]) => {
    // PERF: only dispose of the meshes that changed
    for (let i = 0; i < spawnOutlineMeshes.length; i++) {
      spawnOutlineMeshes[i].dispose();
    }
    spawnOutlineMeshes = [];

    for (const spawn of spawns) {
      const { minCoord, maxCoord } = calculateMinMaxRelativeCoordsOfCreation(Creation, spawn.creationId);

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
