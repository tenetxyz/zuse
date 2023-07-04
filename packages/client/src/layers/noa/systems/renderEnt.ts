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
  // (async () => {
  //   const res = await SceneLoader.ImportMeshAsync(null, "/assets/models/", "table.gltf", scene);
  //   const mesh = res.meshes[0];
  //   mesh.normalizeToUnitCube();
  //   mesh.position.set(voxelCoord.x, voxelCoord.y + 1, voxelCoord.z);
  //   const camera = scene.cameras[0];
  //   console.log(camera.isInFrustum(mesh));
  // })();
  // SceneLoader.ImportMesh("", "/assets/models/", "table.gltf", scene, (newMeshes) => {
  //   for (let m of newMeshes) {
  //     // const mesh = newMeshes[0];
  //     // const mesh = newMeshes[0].clone("new mesh", scene.rootNodes()[0]);
  //     const mesh = m as Mesh;
  //     mesh.computeWorldMatrix(true);
  //     mesh.normalizeToUnitCube();
  //     mesh.optimizeIndices;
  //     // mesh.scaling = new Vector3(25, 25, 25);
  //     mesh.position.set(voxelCoord.x, voxelCoord.y + 1, voxelCoord.z);
  //     const camera = scene.cameras[0];
  //     console.log(camera.isInFrustum(mesh));

  //     // mesh.isVisible = false;
  //     // for (let index = 0; index < 2; index++) {
  //     //   var newInstance = mesh.createInstance("i" + index);
  //     //   newInstance.position.x = voxelCoord.x;
  //     //   newInstance.position.z = voxelCoord.z;
  //     //   newInstance.position.y = voxelCoord.y + 1;
  //     // }
  //   }
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
  // });
};
