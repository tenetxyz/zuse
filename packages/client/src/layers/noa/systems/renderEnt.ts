import { SceneLoader } from "@babylonjs/core";
import '@babylonjs/loaders/glTF';
import { NoaLayer } from ".."
import { VoxelCoord } from "@latticexyz/utils";
// import FileLoader from "./gltfFileLoader"

// sad this didn't work: https://forum.babylonjs.com/t/babylonjs-viewer-load-error-unable-to-import-meshes-from/25974/3
export const renderEnt = (noaLayer: NoaLayer, voxelCoord: VoxelCoord) => {
    const {
        noa
    } = noaLayer;
    const newEntity = noa.entities.add()
    const scene = noa.rendering.getScene();

    console.log("is plugin available");
    console.log(SceneLoader.IsPluginForExtensionAvailable('.gltf'));
    // SceneLoader.ImportMesh("", 'https://bafkreihdudhfdos7nfhtmi2eijqmnfpiig3qfjxr6yfxppk5hdulse5e6a.ipfs.nftstorage.link', "", scene, (res) => {
    // debugger
    // }, (err) => {
    //   debugger
    // });
    // maybe it fails cause the url is not a .gltf file?
    // SceneLoader.ImportMeshAsync(null, "https://bafkreihdudhfdos7nfhtmi2eijqmnfpiig3qfjxr6yfxppk5hdulse5e6a.ipfs.nftstorage.link/", "", scene)
    // SceneLoader.ImportMeshAsync("", '../../../../public/assets/models/', "table.gltf", scene)
    // This page helped mehttps://forum.babylonjs.com/t/loaders-doesnt-work/29223
    // SceneLoader.ImportMeshAsync(["mesh"], 'https://bafkreihdudhfdos7nfhtmi2eijqmnfpiig3qfjxr6yfxppk5hdulse5e6a.ipfs.nftstorage.link', "", scene, null, '.gltf')
    // SceneLoader.ImportMeshAsync(["mesh"], '../../../../public/assets/models/', "mouth.gltf", scene, null, '.gltf')
    SceneLoader.ImportMeshAsync(["mesh"], '/assets/models/', "table.glb", scene, (onSuccess ) => {
        console.log("success")
        console.log(onSuccess)
        //  for(const mesh of onSuccess.json.meshes){
        //   mesh.position.set(voxelCoord.x, voxelCoord.y, voxelCoord.z);
        //   noa.rendering.addMeshToScene(mesh, false);
        //  }
    }, '.gltf')
      .then((result) => {
        // Do something with the loaded meshes if needed
         // Access the loaded mesh
         console.log("then result")
         console.log(result)
      })
      .catch((error) => {
        console.error('Error loading glTF model:', error);
      });
    // SceneLoader.ImportMesh("", '/assets/models/', "table.glb", scene, (success) => {
    //   // onsuccess
    //   console.log("success");
    //   console.log(success)
    // }, (progress:any) => {
    //   // on progress
    //   // debugger
    //      for(const mesh of progress.json.meshes){
    //       mesh.position.set(voxelCoord.x, voxelCoord.y, voxelCoord.z);
    //       noa.rendering.addMeshToScene(mesh, false);
    //      }
    //      console.log("progress");
    //      console.log(progress);
    // },
    // (err) => {
    //   debugger
    //   console.warn(err)
    // }, '.gltf');
}