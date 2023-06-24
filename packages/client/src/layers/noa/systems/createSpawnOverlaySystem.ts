// the purpose of this system is to render a wireframe around voxels/creations the user selects

import { NetworkLayer } from "../../network";
import { NoaLayer } from "../types";
import { renderChunkyWireframe } from "./renderWireframes";
import { Color3, Mesh } from "@babylonjs/core";
import { add } from "../../../utils/coord";
import { calculateMinMaxRelativePositions } from "../../../utils/creation";
import { Entity, EntitySymbol, getComponentValue } from "@latticexyz/recs";
import { to256BitString, VoxelCoord } from "@latticexyz/utils";

interface Spawn {
  spawnId: Entity;
  creationId: Entity;
  lowerSouthWestCorner: VoxelCoord;
  voxels: Entity[];
  interfaceVoxels: Entity[];
}

// All creations that are spawned will have an overlay around them
// This is so when people modify a spawned creation, they know they are modifying that spawn instance
export function createSpawnOverlaySystem(
  networkLayer: NetworkLayer,
  noaLayer: NoaLayer
) {
  const { noa } = noaLayer;
  const {
    contractComponents: { Spawn, Creation },
  } = networkLayer;

  Spawn.update$.subscribe((update) => {
    const spawnTable = update.component?.values;
    if (spawnTable === undefined) {
      return;
    }
    const spawns: Spawn[] = [];
    spawnTable.creationId.forEach((creationId, rawSpawnId) => {
      const spawnId = rawSpawnId as any;
      spawns.push({
        spawnId: spawnId,
        creationId: creationId as Entity,
        lowerSouthWestCorner: {
          x: spawnTable.lowerSouthWestCornerX.get(spawnId)!,
          y: spawnTable.lowerSouthWestCornerY.get(spawnId)!,
          z: spawnTable.lowerSouthWestCornerZ.get(spawnId)!,
        },
        voxels: spawnTable.voxels.get(spawnId) as Entity[],
        interfaceVoxels: spawnTable.interfaceVoxels.get(spawnId) as Entity[],
      });
    });
    renderSpawnOutlines(spawns);
  });

  let spawnOutlineMeshes: Mesh[] = [];
  const renderSpawnOutlines = (spawns: Spawn[]) => {
    // PERF: only dispose of the meshes that changed
    for (let i = 0; i < spawnOutlineMeshes.length; i++) {
      spawnOutlineMeshes[i].dispose();
    }
    spawnOutlineMeshes = [];

    for (const spawn of spawns) {
      const creation = getComponentValue(Creation, spawn.creationId);
      if (creation === undefined) {
        console.error(
          `cannot render spawn outline without finding the corresponding creation. spawnId=${spawn.spawnId} creationId=${spawn.creationId}`
        );
        continue;
      }

      const xPositions = creation.relativePositionsX ?? [];
      const yPositions = creation.relativePositionsY ?? [];
      const zPositions = creation.relativePositionsZ ?? [];

      if (
        xPositions.length === 0 ||
        yPositions.length === 0 ||
        zPositions.length === 0
      ) {
        console.warn(
          `No relativePositions found for creationId=${creationId.toString()}. xPositions=${xPositions} yPositions=${yPositions} zPositions=${zPositions}`
        );
        return;
      }

      const relativePositions = xPositions.map((x, i) => {
        return { x, y: yPositions[i], z: zPositions[i] };
      });

      const { minRelativeCoord, maxRelativeCoord } =
        calculateMinMaxRelativePositions(relativePositions);

      const corner1 = add(spawn.lowerSouthWestCorner, minRelativeCoord);
      const corner2 = add(spawn.lowerSouthWestCorner, maxRelativeCoord);

      const mesh = renderChunkyWireframe(
        corner1,
        corner2,
        noa,
        new Color3(1, 1, 0), // yellow
        0.05
      );
      if (mesh !== null) {
        spawnOutlineMeshes.push(mesh);
      }
    }
  };
}
