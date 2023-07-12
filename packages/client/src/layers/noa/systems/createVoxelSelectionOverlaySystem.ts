// the purpose of this system is to render a wireframe around voxels/creations the user selects

import { NetworkLayer } from "../../network";
import { InterfaceVoxel, NoaLayer } from "../types";
import { renderChunkyWireframe } from "./renderWireframes";
import { Color3, Mesh, Nullable } from "@babylonjs/core";
import { ComponentRecord } from "../../../types";
import { stringToVoxelCoord } from "../../../utils/coord";
import { getComponentValue } from "@latticexyz/recs";

export function createVoxelSelectionOverlaySystem(network: NetworkLayer, noaLayer: NoaLayer) {
  const {
    components: { VoxelSelection, VoxelInterfaceSelection },
    noa,
  } = noaLayer;
  const {
    components: { Position },
  } = network;
  type IVoxelSelection = ComponentRecord<typeof VoxelSelection>;
  VoxelSelection.update$.subscribe((update) => {
    const voxelSelection = update.value[0] as IVoxelSelection;
    renderRangeSelection(voxelSelection);
  });

  let renderedRangeSelectionMesh: Nullable<Mesh> = null;
  const renderRangeSelection = (voxelSelection: IVoxelSelection) => {
    if (renderedRangeSelectionMesh) {
      // remove the previous mesh since the user can only have one range selection
      renderedRangeSelectionMesh.dispose();
    }

    if (!voxelSelection.corner1 && !voxelSelection.corner2) {
      // none of the corners are defined, so render nothing
      return;
    }
    renderedRangeSelectionMesh = renderChunkyWireframe(
      voxelSelection.corner1 ?? voxelSelection.corner2!,
      voxelSelection.corner2 ?? voxelSelection.corner1!,
      noa,
      new Color3(1, 1, 1),
      0.05
    );
  };

  type IVoxelInterfaceSelection = ComponentRecord<typeof VoxelInterfaceSelection>;
  VoxelInterfaceSelection.update$.subscribe((update) => {
    const voxelInterfaceSelection = update.value[0] as IVoxelInterfaceSelection;
    renderVoxelInterfaceSelection(voxelInterfaceSelection);
  });

  let renderedVoxelInterfaceSelectionMeshs: Nullable<Mesh>[] = [];
  const renderVoxelInterfaceSelection = (voxelInterfaceSelection: IVoxelInterfaceSelection) => {
    if (renderedVoxelInterfaceSelectionMeshs) {
      // remove the previous mesh since the user can only have one range selection
      renderedVoxelInterfaceSelectionMeshs.forEach((mesh) => mesh?.dispose());
    }

    renderedVoxelInterfaceSelectionMeshs = voxelInterfaceSelection.interfaceVoxels.map(
      (interfaceVoxel: InterfaceVoxel) => {
        const voxelCoord = getComponentValue(Position, interfaceVoxel.entity as Entity);
        if (!voxelCoord) {
          return;
        }

        return renderChunkyWireframe(voxelCoord, voxelCoord, noa, new Color3(1, 0.1, 0.1), 0.04);
      }
    );
  };
}
