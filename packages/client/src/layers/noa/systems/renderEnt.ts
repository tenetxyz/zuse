import { AbstractMesh, ArcRotateCamera, Mesh, SceneLoader, Vector3 } from "@babylonjs/core";
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

  // example of rendering a mesh (marble): https://playground.babylonjs.com/#0108NG#232
  // another example (skull): https://www.babylonjs-playground.com/#1BUQD5#2
  SceneLoader.ImportMesh(
    "",
    // "https://models.babylonjs.com/Marble/marble/",
    // "marble.gltf",
    "/assets/models/",
    "table.gltf",
    scene,
    (newMeshes) => {
      console.log("on success");
      // on success
      const mesh = newMeshes[0];
      // mesh.computeWorldMatrix(true);
      mesh.scaling = new Vector3(1, 1, 1);

      // .position is where the mesh is relative to the world
      // I think absolutePosition is where the mesh is relative to... the mesh's root node? Really not sure
      mesh.position.set(voxelCoord.x, voxelCoord.y, voxelCoord.z);
      // add all the meshes to the noa scene
      for (const newMesh of newMeshes) {
        // important! you have to include the first mesh as well! (the mesh at index 0)
        // Even though newMeshes[0] is added to the babylonjs scene, we still need to ask noa to render it
        // since noa does extra operations (like adding it to the oct tree): https://github.com/fenomas/noa/issues/100
        noa.rendering.addMeshToScene(newMesh);
        newMesh.normalizeToUnitCube();
      }
    },
    (onProgress) => {
      console.log("progress", onProgress);
    },
    (onError) => {
      console.log("onError", onError);
    }
  );
};
