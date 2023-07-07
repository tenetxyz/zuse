// the purpose of this system is to render a wireframe around voxels/creations the user selects

import { NetworkLayer } from "../../network";
import { NoaLayer } from "../types";
import { renderChunkyWireframe } from "./renderWireframes";
import { Color3, Mesh, Nullable } from "@babylonjs/core";
import { ISpawnCreation } from "../components/SpawnCreation";
import { Creation } from "../../react/components/CreationStore";
import { add } from "../../../utils/coord";
import { VoxelCoord } from "@latticexyz/utils";
import { TargetedBlock } from "../../../utils/voxels";

export function createSpawnCreationOverlaySystem(network: NetworkLayer, noaLayer: NoaLayer) {
  const {
    components: { SpawnCreation },
    noa,
  } = noaLayer;

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

    renderCreationOutline(creationToSpawn, targetedBlock);
  };

  const renderCreationOutline = (creation: Creation, targetedBlock: TargetedBlock) => {
    const { corner1, corner2 } = calculateCornersFromTargetedBlock(creation, targetedBlock);
    renderedCreationOutlineMesh = renderChunkyWireframe(corner1, corner2, noa, new Color3(0, 0, 1), 0.05);
  };
  // TODO: once we have rendered the right outline mesh, we need to also use this coord for the spawning location
}

export const calculateCornersFromTargetedBlock = (creation: Creation, targetedBlock: TargetedBlock) => {
  const {
    adjacent: [x, y, z],
    normal: [normalX, normalY, normalZ],
  } = targetedBlock;

  let { minRelativeCoord, maxRelativeCoord } = calculateMinMaxRelativeCoordsOfCreation(creation);
  const height = maxRelativeCoord.y - minRelativeCoord.y;
  const width = maxRelativeCoord.x - minRelativeCoord.x;
  const depth = maxRelativeCoord.z - minRelativeCoord.z;

  // shift the coordinates so we are always placing the creation on the side we're facing
  if (normalY === -1) {
    minRelativeCoord.y -= height;
    maxRelativeCoord.y -= height;
  } else if (normalX === -1) {
    minRelativeCoord.x -= width;
    maxRelativeCoord.x -= width;
  } else if (normalZ === -1) {
    minRelativeCoord.z -= depth;
    maxRelativeCoord.z -= depth;
  }

  const targetVoxelCoord: VoxelCoord = { x, y, z };
  const corner1 = add(targetVoxelCoord, minRelativeCoord);
  const corner2 = add(targetVoxelCoord, maxRelativeCoord);
  return { corner1, corner2 };
};

const calculateMinMaxRelativeCoordsOfCreation = (
  creation: Creation
): { minRelativeCoord: VoxelCoord; maxRelativeCoord: VoxelCoord } => {
  // creations should have at least 2 voxels, so we can assume the first one is the min and max
  const minCoord: VoxelCoord = { ...creation.relativePositions[0] }; // clone the coord so we don't mutate the original
  const maxCoord: VoxelCoord = { ...creation.relativePositions[0] };

  for (let i = 1; i < creation.relativePositions.length; i++) {
    const voxelCoord = creation.relativePositions[i];
    minCoord.x = Math.min(minCoord.x, voxelCoord.x);
    minCoord.y = Math.min(minCoord.y, voxelCoord.y);
    minCoord.z = Math.min(minCoord.z, voxelCoord.z);
    maxCoord.x = Math.max(maxCoord.x, voxelCoord.x);
    maxCoord.y = Math.max(maxCoord.y, voxelCoord.y);
    maxCoord.z = Math.max(maxCoord.z, voxelCoord.z);
  }
  return {
    minRelativeCoord: minCoord,
    maxRelativeCoord: maxCoord,
  };
};
