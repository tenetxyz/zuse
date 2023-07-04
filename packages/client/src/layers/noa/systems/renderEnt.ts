import { AbstractMesh, MeshBuilder, SceneLoader, Vector3 } from "@babylonjs/core";
import "@babylonjs/loaders/glTF"; // load the glTF loader plugin
import { NoaLayer } from "..";
import { VoxelCoord } from "@latticexyz/utils";

export const renderEnt = (noaLayer: NoaLayer, voxelCoord: VoxelCoord) => {
  const { noa } = noaLayer;
  const newEntity = noa.entities.add();
  const scene = noa.rendering.getScene();

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
    // example of rendering a mesh: https://playground.babylonjs.com/#0108NG#232
    console.log("newMeshes", newMeshes);
    // noa.rendering.addMeshToScene(newMeshes[0], false);
    for (const mesh of newMeshes) {
      // mesh.setEnabled(false); //this will hide the meshes when loaded
      models[mesh.name] = mesh; //add them to our models-object, we will call them later via their name
      mesh.setAbsolutePosition(new Vector3(voxelCoord.x, voxelCoord.y, voxelCoord.z));
      // mesh.position = new Vector3(voxelCoord.x, voxelCoord.y, voxelCoord.z);
      // noa.rendering.addMeshToScene(mesh, false);
    }
    console.log("second");
    console.log(scene.meshes);
  });
};
