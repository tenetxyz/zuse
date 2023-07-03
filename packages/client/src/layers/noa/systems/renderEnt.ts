import { SceneLoader } from "@babylonjs/core";
import { NoaLayer } from ".."
import { VoxelCoord } from "@latticexyz/utils";

export const renderEnt = (noaLayer: NoaLayer, voxelCoord: VoxelCoord) => {
    const {
        noa
    } = noaLayer;
    const newEntity = noa.entities.add()
    const scene = noa.rendering.getScene();

    // SceneLoader.ImportMeshAsync("", './assets/models/', "table.gltf", scene)
    // SceneLoader.ImportMesh("", 'https://bafkreihdudhfdos7nfhtmi2eijqmnfpiig3qfjxr6yfxppk5hdulse5e6a.ipfs.nftstorage.link', "", scene, (res) => {
    // debugger
    // }, (err) => {
    //   debugger
    // });
    SceneLoader.ImportMeshAsync("", "https://bafkreihdudhfdos7nfhtmi2eijqmnfpiig3qfjxr6yfxppk5hdulse5e6a.ipfs.nftstorage.link", "", scene)
      .then((result) => {
        // Do something with the loaded meshes if needed
         // Access the loaded mesh
         debugger
         const mesh = result.meshes[0];

         mesh.position.set(voxelCoord.x, voxelCoord.y, voxelCoord.z);
         noa.rendering.addMeshToScene(mesh, false);
      })
      .catch((error) => {
        console.error('Error loading glTF model:', error);
      });
}