// the purpose of this system is to render a wireframe around voxels/creations the user selects

import { NetworkLayer } from "../../network";
import { NoaLayer } from "../types";
import { renderChunkyWireframe } from "./renderWireframes";
import { Color3, Mesh } from "@babylonjs/core";
import { add, calculateMinMaxRelativeCoordsOfCreation, decodeCoord, getWorldScale } from "../../../utils/coord";
import { Entity } from "@latticexyz/recs";
import { VoxelCoord, awaitStreamValue } from "@latticexyz/utils";
import { ISpawn } from "../components/SpawnInFocus";
import { abiDecode } from "@/utils/encodeOrDecode";

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
    registryComponents: { VoxelTypeRegistry },
  } = networkLayer;

  // I think there's an implicit assumption here that the spawn is done loading.
  Spawn.update$.subscribe((update) => {
    const spawnTable = update.component?.values;
    if (spawnTable === undefined) {
      return;
    }
    renderSpawnOutlines();
  });

  // when the player zooms to a different level, we need to re-render the spawn outlines (since voxels on a spawn may not exist on that level)
  noa.on("newWorldName", (_newWorldName: string) => {
    renderSpawnOutlines();
  });

  const createSpawnArray = (): ISpawn[] => {
    const spawns: ISpawn[] = [];
    const spawnTable = Spawn.values;
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
    return spawns;
  };

  let spawnOutlineMeshes: Mesh[] = [];
  const renderSpawnOutlines = () => {
    const spawns = createSpawnArray();
    // PERF: only dispose of the meshes that changed
    for (let i = 0; i < spawnOutlineMeshes.length; i++) {
      spawnOutlineMeshes[i].dispose();
    }
    spawnOutlineMeshes = [];
    const scale = getWorldScale(noa);

    for (const spawn of spawns) {
      const { minCoord, maxCoord } = calculateMinMaxRelativeCoordsOfCreation(
        VoxelTypeRegistry,
        Creation,
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
