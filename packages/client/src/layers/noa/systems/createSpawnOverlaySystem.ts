// the purpose of this system is to render a wireframe around voxels/creations the user selects

import { NetworkLayer } from "../../network";
import { NoaLayer } from "../types";
import { renderChunkyWireframe } from "./renderWireframes";
import { Color3, Mesh, Nullable } from "@babylonjs/core";
import { add, calculateMinMaxCoords, decodeCoord } from "../../../utils/coord";
import { Entity, EntitySymbol, getComponentValue } from "@latticexyz/recs";
import { to256BitString, VoxelCoord } from "@latticexyz/utils";
import { abiDecode } from "../../../utils/abi";
import { ISpawn } from "../components/SpawnInFocus";

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
      if (lowerSouthWestCorner) {
        spawns.push({
          spawnId: spawnId,
          creationId: creationId as Entity,
          lowerSouthWestCorner: lowerSouthWestCorner,
          voxels: spawnTable.voxels.get(spawnId) as Entity[],
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
      // PERF: if users tend to spawn the same creation multiple times we should memoize the creation fetching process
      const creation = getComponentValue(Creation, spawn.creationId);
      if (creation === undefined) {
        console.error(
          `cannot render spawn outline without finding the corresponding creation. spawnId=${spawn.spawnId} creationId=${spawn.creationId}`
        );
        continue;
      }

      // calculate the min and max relative positions of the creation so we can render the wireframe around it
      const relativePositions =
        (abiDecode("tuple(int32 x,int32 y,int32 z)[]", creation.relativePositions) as VoxelCoord[]) || [];

      if (relativePositions.length === 0) {
        console.warn(
          `No relativePositions found for creationId=${spawn.creationId.toString()}. relativePositions=${relativePositions}`
        );
        return;
      }

      const { minCoord, maxCoord } = calculateMinMaxCoords(relativePositions);

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
