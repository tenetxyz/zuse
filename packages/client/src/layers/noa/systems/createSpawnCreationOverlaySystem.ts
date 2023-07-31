// the purpose of this system is to render a wireframe around voxels/creations the user selects

import { NetworkLayer } from "../../network";
import { NoaLayer } from "../types";
import { renderChunkyWireframe } from "./renderWireframes";
import { Color3, Mesh, Nullable } from "@babylonjs/core";
import { ISpawnCreation } from "../components/SpawnCreation";
import { Creation } from "../../react/components/CreationStore";
import { add, calculateMinMaxRelativeCoordsOfCreation, getWorldScale } from "../../../utils/coord";
import { VoxelCoord } from "@latticexyz/utils";
import { TargetedBlock } from "../../../utils/voxels";
import { Engine } from "noa-engine";

export function createSpawnCreationOverlaySystem(network: NetworkLayer, noaLayer: NoaLayer) {
  const {
    components: { SpawnCreation },
    noa,
  } = noaLayer;
  const {
    contractComponents: { Creation },
    registryComponents: { VoxelTypeRegistry },
  } = network;

  let creationToSpawn: Creation | undefined;
  let targetedBlock: TargetedBlock | undefined;

  let renderedCreationOutlineMesh: Nullable<Mesh> = null;
  noa.on("targetBlockChanged", (newTargetedBlock: TargetedBlock) => {
    targetedBlock = newTargetedBlock;
    tryRenderOutline();
  });

  SpawnCreation.update$.subscribe((update) => {
    creationToSpawn = (update.value[0] as ISpawnCreation)?.creation;
    tryRenderOutline();
  });

  const tryRenderOutline = () => {
    if (renderedCreationOutlineMesh) {
      // remove the previous mesh since the user may have moved their targetedblock
      renderedCreationOutlineMesh.dispose();
    }

    // Note: we do NOT check for !noa.container.hasPointerLock since if the inventory did not close in time, we will not see the spawning outline right away
    if (!targetedBlock || !creationToSpawn) {
      return;
    }

    renderCreationOutline(creationToSpawn);
  };

  const renderCreationOutline = (creation: Creation) => {
    const { corner1, corner2 } = calculateCornersFromTargetedBlock(
      noa,
      VoxelTypeRegistry,
      Creation,
      creation,
    );
    renderedCreationOutlineMesh = renderChunkyWireframe(corner1, corner2, noa, new Color3(0, 0, 1), 0.05);
  };
  // TODO: once we have rendered the right outline mesh, we need to also use this coord for the spawning location
}

export const calculateCornersFromTargetedBlock = (
  noa: Engine,
  VoxelTypeRegistry: any,
  Creation: any,
  creation: Creation,
) => {
  const {
    adjacent: [x, y, z],
    normal: [normalX, normalY, normalZ],
  } = noa.targetedBlock!;

  const { minCoord, maxCoord } = calculateMinMaxRelativeCoordsOfCreation(
    VoxelTypeRegistry,
    Creation,
    creation.creationId,
    getWorldScale(noa)
  );
  const height = maxCoord.y - minCoord.y;
  const width = maxCoord.x - minCoord.x;
  const depth = maxCoord.z - minCoord.z;

  // shift the coordinates so we are always placing the creation on the side we're facing
  if (normalY === -1) {
    minCoord.y -= height;
    maxCoord.y -= height;
  } else if (normalX === -1) {
    minCoord.x -= width;
    maxCoord.x -= width;
  } else if (normalZ === -1) {
    minCoord.z -= depth;
    maxCoord.z -= depth;
  }

  const targetVoxelCoord: VoxelCoord = { x, y, z };
  const corner1 = add(targetVoxelCoord, minCoord);
  const corner2 = add(targetVoxelCoord, maxCoord);
  return { corner1, corner2 };
};
