import { AbstractMesh, Mesh, MeshBuilder, SceneLoader, SimplificationType, Vector3 } from "@babylonjs/core";
import "@babylonjs/loaders/glTF"; // load the glTF loader plugin
import { NoaLayer } from "..";
import { VoxelCoord } from "@latticexyz/utils";
import { Scene } from "@babylonjs/core";

export const renderEnt = (noaLayer: NoaLayer, voxelCoord: VoxelCoord) => {
  const { noa } = noaLayer;
  const newEntity = noa.entities.add();
  const scene: Scene = noa.rendering.getScene();

  // Note: it's imprtant to check that we have imported the glTF loader plugin before trying to use it
  // If we are going to support other formats, please do a check like this when developing!
  // console.log("is plugin available");
  // console.log(SceneLoader.IsPluginForExtensionAvailable('.gltf'));

  interface Models {
    [name: string]: AbstractMesh;
  }

  // This thread says to use setAbsolutePosition?
  // https://forum.babylonjs.com/t/set-global-position-of-a-mesh/2476/2
  const models: Models = {};
  console.log("first");
  console.log(scene.meshes);

  // SceneLoader.ImportMesh("", "/assets/models/", "table.gltf", scene, (newMeshes) => {
  SceneLoader.ImportMesh("", "https://models.babylonjs.com/Marble/marble/", "marble.gltf", scene, (newMeshes) => {
    for (const mesh of newMeshes) {
      // const mesh = newMeshes[0];
      // const mesh = newMeshes[0].clone("new mesh", scene.rootNodes()[0]);
      mesh.normalizeToUnitCube();
      mesh.position.set(voxelCoord.x, voxelCoord.y + 1, voxelCoord.z);
      // noa.rendering.addMeshToScene(mesh, false);
      console.log(mesh);
    }
    // example of rendering a mesh (marble): https://playground.babylonjs.com/#0108NG#232
    // another example (skull): https://www.babylonjs-playground.com/#1BUQD5#2
    // console.log("newMeshes", newMeshes);
    // // noa.rendering.addMeshToScene(newMeshes[0], false);
    // for (const mesh of newMeshes) {
    //   // mesh.setEnabled(false); //this will hide the meshes when loaded
    //   models[mesh.name] = mesh; //add them to our models-object, we will call them later via their name
    //   mesh.normalizeToUnitCube();
    //   // mesh.setAbsolutePosition(new Vector3(voxelCoord.x, voxelCoord.y, voxelCoord.z));
    //   // mesh.position = new Vector3(voxelCoord.x, voxelCoord.y, voxelCoord.z);
    //   mesh.position.set(voxelCoord.x, voxelCoord.y, voxelCoord.z);
    //   noa.rendering.addMeshToScene(mesh, false);
    //   if (mesh instanceof Mesh) {
    //     console.log("is mesh!");
    //   }
    //   break;
    // }
    // console.log("second");
    // console.log(scene.meshes);
  });
};
