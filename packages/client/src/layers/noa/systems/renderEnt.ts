import { SceneLoader } from "@babylonjs/core";
import { NoaLayer } from ".."
import { VoxelCoord } from "@latticexyz/utils";

export const renderEnt = (noaLayer: NoaLayer, voxelCoord: VoxelCoord) => {
    const {
        noa
    } = noaLayer;
    const newEntity = noa.entities.add()
    const scene = noa.rendering.getScene();

    SceneLoader.ImportMeshAsync(null, 'assets/models/', 'mouth.gltf', scene)
      .then((result) => {
        // Do something with the loaded meshes if needed
         // Access the loaded mesh
         const mesh = result.meshes[0];

         mesh.position.set(voxelCoord.x, voxelCoord.y, voxelCoord.z);
         noa.rendering.addMeshToScene(mesh, false);
      })
      .catch((error) => {
        console.error('Error loading glTF model:', error);
      });
}