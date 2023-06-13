// the purpose of this system is to render a wireframe around voxels/creations the user selects

import { NetworkLayer } from "../../network";
import { NoaLayer } from "../types";
import { renderChunkyWireframe } from "./renderWireframes";
import { IVoxelSelection } from "../components/VoxelSelection";
import { Mesh, Nullable } from "@babylonjs/core";

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
    renderPointSelection();
  });

  let renderedRangeSelectionMesh: Nullable<Mesh> = null;
  const renderRangeSelection = (voxelSelection: IVoxelSelection) => {
    if (!voxelSelection.corner1 || !voxelSelection.corner2) {
      return;
    }
    if (renderedRangeSelectionMesh) {
      renderedRangeSelectionMesh.dispose();
    }
    renderedRangeSelectionMesh = renderChunkyWireframe(
      voxelSelection.corner1,
      voxelSelection.corner2,
      noa
    );
  };
  const renderPointSelection = () => {};
}
