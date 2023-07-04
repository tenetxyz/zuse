import { AbstractMesh, Mesh, MeshBuilder, SceneLoader, SimplificationType, Vector3 } from "@babylonjs/core";
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

    newMeshes[0].normalizeToUnitCube();
    var i;
    var len;
    //for(i=0 , len=newMeshes.length; i<len ; i++){
    var m = newMeshes[1] as Mesh;
    m.optimizeIndices(function () {
      m.simplify(
        [
          { distance: 5, quality: 0.5 },
          // { distance: 7, quality: 0.4 },
          // { distance: 6, quality: 0.6 },
          // { distance: 5, quality: 0.8 },
          // { distance: 3, quality: 1}
        ],
        false,
        SimplificationType.QUADRATIC,
        function () {
          // console.log("YES !!!!");
          // var simplified = m.getLODLevelAtDistance(5)
          // console.log(simplified);
          // doDownload("test4",simplified);
          // //Before
          // //console.log(scene.meshes[7]);
          // //doDownload("test4",scene.meshes[7]);
        }
      );
    });
  });
};
