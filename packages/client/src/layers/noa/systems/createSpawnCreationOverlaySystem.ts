// the purpose of this system is to render a wireframe around voxels/creations the user selects

import { NetworkLayer } from "../../network";
import { NoaLayer } from "../types";
import { renderChunkyWireframe } from "./renderWireframes";
import { IVoxelSelection } from "../components/VoxelSelection";
import { Color3, Mesh, Nullable } from "@babylonjs/core";
import {
  getNoaComponent,
  getNoaComponentStrict,
} from "../engine/components/utils";
import {
  MINING_VOXEL_COMPONENT,
  MiningVoxelComponent,
} from "../engine/components/miningVoxelComponent";
import {
  HAND_COMPONENT,
  HandComponent,
} from "../engine/components/handComponent";
import { ISpawnCreation } from "../components/SpawnCreation";
import { Creation } from "../../react/components/CreationStore";
import { add } from "../../../utils/coord";
import { VoxelCoord } from "@latticexyz/utils";

export function createSpawnCreationOverlaySystem(
  network: NetworkLayer,
  noaLayer: NoaLayer
) {
  const {
    components: { SpawnCreation },
    noa,
  } = noaLayer;

  let creationToSpawn: Creation | undefined;

  type TargetedBlock = { position: number[] };

  noa.on("targetBlockChanged", (targetedBlock: TargetedBlock) => {
    if (!noa.container.hasPointerLock) return;
    if (!targetedBlock) {
      return;
    }
    if (!creationToSpawn) {
      return;
    }

    renderCreationOutline(creationToSpawn, targetedBlock);
  });

  let renderedCreationOutlineMesh: Nullable<Mesh> = null;
  SpawnCreation.update$.subscribe((update) => {
    if (renderedCreationOutlineMesh) {
      // remove the previous mesh since the user can only spawn one creation at a time
      renderedCreationOutlineMesh.dispose();
    }

    creationToSpawn = (update.value[0] as ISpawnCreation)?.creation;
  });

  const renderCreationOutline = (
    creation: Creation,
    targetedBlock: TargetedBlock
  ) => {
    const {
      position: [x, y, z],
    } = targetedBlock;

    const { minRelativeCoord, maxRelativeCoord } =
      calculateMinMaxRelativeCoordsOfCreation(creation);

    const targetVoxelCoord: VoxelCoord = { x, y, z };
    const corner1 = add(targetVoxelCoord, minRelativeCoord);
    const corner2 = add(targetVoxelCoord, maxRelativeCoord);
    // debugger;
    renderedCreationOutlineMesh = renderChunkyWireframe(
      corner1,
      corner2,
      noa,
      new Color3(1, 1, 1),
      0.05
    );
  };

  const calculateMinMaxRelativeCoordsOfCreation = (
    creation: Creation
  ): { minRelativeCoord: VoxelCoord; maxRelativeCoord: VoxelCoord } => {
    // creations should have at least 2 voxels, so we can assume the first one is the min and max
    const minCoord: VoxelCoord = creation.relativePositions[0];
    const maxCoord: VoxelCoord = creation.relativePositions[0];

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
}
