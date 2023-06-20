// the purpose of this system is to render a wireframe around voxels/creations the user selects

import { NetworkLayer } from "../../network";
import { NoaLayer } from "../types";
import { renderChunkyWireframe } from "./renderWireframes";
import { IVoxelSelection } from "../components/VoxelSelection";
import { Color3, Mesh, Nullable } from "@babylonjs/core";

export function createVoxelSelectionOverlaySystem(
  network: NetworkLayer,
  noaLayer: NoaLayer
) {
  const {
    components: { VoxelSelection },
    noa,
  } = noaLayer;

  VoxelSelection.update$.subscribe((update) => {
    const voxelSelection = update.value[0] as IVoxelSelection;
    renderRangeSelection(voxelSelection);
    renderPointSelection(voxelSelection);
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

  let renderedPointSelectionMeshes: Nullable<Mesh>[] = [];
  const renderPointSelection = (voxelSelection: IVoxelSelection) => {
    // remove the previous meshes since we're re-rendering all of them
    // if this is a performance hit, we can cache the meshes and only render the new selections
    renderedPointSelectionMeshes.forEach((mesh) => mesh?.dispose());

    renderedPointSelectionMeshes =
      voxelSelection.points?.map((point) => {
        return renderChunkyWireframe(
          point,
          point,
          noa,
          new Color3(1, 0.1, 0.1),
          0.04
        );
      }) ?? [];
  };
}
