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

  // This thread says to use setAbsolutePosition?
  // https://forum.babylonjs.com/t/set-global-position-of-a-mesh/2476/2
  const models: Models = {};
  // (async () => {
  //   const res = await SceneLoader.ImportMeshAsync(null, "/assets/models/", "table.gltf", scene);
  //   const mesh = res.meshes[0];
  //   mesh.normalizeToUnitCube();
  //   mesh.position.set(voxelCoord.x, voxelCoord.y + 1, voxelCoord.z);
  //   const camera = scene.cameras[0];
  //   console.log(camera.isInFrustum(mesh));
  // })();
  SceneLoader.ImportMesh(
    "",
    "https://models.babylonjs.com/Marble/marble/",
    "marble.gltf",
    scene,
    (newMeshes) => {
      console.log("on success");
      // example of rendering a mesh (marble): https://playground.babylonjs.com/#0108NG#232
      // another example (skull): https://www.babylonjs-playground.com/#1BUQD5#2
      for (const newMesh of newMeshes) {
        noa.rendering.addMeshToScene(newMesh);
      }

      // on success
      const mesh = newMeshes[0];
      // mesh.computeWorldMatrix(true);
      mesh.normalizeToUnitCube();
      mesh.scaling = new Vector3(25, 25, 25);
      mesh.position.set(voxelCoord.x, voxelCoord.y + 2, voxelCoord.z);
      const camera = scene.cameras[0];
      console.log(camera.isInFrustum(mesh));
      console.log(newMeshes);
      console.log(newMeshes.map((mesh) => mesh.id));
    },
    (onProgress) => {
      console.log("progress", onProgress);
    },
    (onError) => {
      console.log("onError", onError);
    }
  );
};
