// the purpose of this system is to render a wireframe around voxels/creations the user selects

import { NetworkLayer } from "../../network";
import { NoaLayer } from "../types";
import { renderChunkyWireframe } from "./renderWireframes";
import { Color3, Mesh, Nullable } from "@babylonjs/core";
import { add, calculateMinMaxCoords, decodeCoord, stringToVoxelCoord, voxelCoordToString } from "../../../utils/coord";
import { Entity, EntitySymbol, getComponentValue, getComponentValueStrict } from "@latticexyz/recs";
import { to256BitString, VoxelCoord } from "@latticexyz/utils";
import { abiDecode } from "../../../utils/abi";
import { ISpawn } from "../components/SpawnInFocus";

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
      const relativeVoxelCoords = getVoxelCoordsOfCreation(spawn.creationId);
      const { minCoord, maxCoord } = calculateMinMaxCoords(relativeVoxelCoords);

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

  const getVoxelCoordsOfCreation = (creationId: Entity): VoxelCoord[] => {
    // PERF: if users tend to spawn the same creation multiple times we should memoize the creation fetching process
    const creation = getComponentValueStrict(Creation, creationId);
    const voxelCoords =
      (abiDecode("tuple(uint32 x,uint32 y,uint32 z)[]", creation.relativePositions) as VoxelCoord[]) || [];
    const baseCreations = abiDecode(
      "tuple(bytes32 creationId,tuple(int32 x,int32 y,int32 z) coordOffset,tuple(int32 x,int32 y,int32 z)[] deletedRelativeCoords)[]",
      creation.baseCreations
    ) as BaseCreation[];

    for (const baseCreation of baseCreations) {
      const baseCreationVoxelCoords = getVoxelCoordsOfCreation(baseCreation.creationId);
      const uniqueCoords = new Set<string>(baseCreationVoxelCoords.map(voxelCoordToString));
      for (const deletedRelativeCoord of baseCreation.deletedRelativeCoords) {
        uniqueCoords.delete(voxelCoordToString(deletedRelativeCoord));
      }
      voxelCoords.push(...Array.from(uniqueCoords).map(stringToVoxelCoord));
    }
    return voxelCoords;
  };
}
