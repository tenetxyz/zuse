import { AbstractMesh, ArcRotateCamera, BoundingInfo, Mesh, MeshBuilder, SceneLoader, Vector3 } from "@babylonjs/core";
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

  // TODO: I couldn't get it to render from the nftstorage link. Maybe the headers don't say it's glTF?
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
      mesh.scaling = new Vector3(1, 1, 1);
      // centerMesh(newMeshes, scene);

      // TODO: we need to find a way to center the mesh around its local origin so all meshes appear at the specified voxelCoord
      // changing the absolutePosition of each mesh DOESN't work
      // For now, we should just ask people to give an offset to the mesh so when it's spawned, it's spawned with that offset
      // This is because some players may want their mesh to be NOT be centered (e.g. a mirror may be closer to the wall)
      // The downside is they have to spend more time into figuring out this offset (since an offset of 0.5 isn't the same for each mesh rn - because meshes aren't centered)
      // console.log(mesh.position);
      // console.log(mesh.getAbsolutePivotPoint());
      // console.log(mesh.getPivotPoint());

      // https://www.html5gamedevs.com/topic/35219-position-vs-absoluteposition/
      // The position is the object's position in its own coordinate system.
      // If you simply place an object in a scene, it's position and absolute position will technically be the same.
      // mesh.position.set(voxelCoord.x + 0.5, voxelCoord.y + 1.5, voxelCoord.z + 0.5);
      mesh.setAbsolutePosition(new Vector3(voxelCoord.x + 0.5, voxelCoord.y + 1.5, voxelCoord.z + 0.5));

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

// This centering thing doesn't work. Since the mesh already thinks it's centered on 0,0,0
// I tried looking into changing the pivot point as well, but the pivot also says it's on 0,0,0
// Right now, I just can't figure out how to center it
// from https://playground.babylonjs.com/#U5SSCN#24
// from https://discourse.threejs.org/t/centering-a-gltf-geometry/6841
const centerMesh = (meshes: AbstractMesh[], scene: Scene) => {
  let min: null | Vector3 = null;
  let max: null | Vector3 = null;
  meshes.forEach(function (mesh) {
    const boundingBox = mesh.getBoundingInfo().boundingBox;
    if (min === null) {
      min = new Vector3();
      min.copyFrom(boundingBox.minimum);
    }

    if (max === null) {
      max = new Vector3();
      max.copyFrom(boundingBox.maximum);
    }

    min.x = boundingBox.minimum.x < min.x ? boundingBox.minimum.x : min.x;
    min.y = boundingBox.minimum.y < min.y ? boundingBox.minimum.y : min.y;
    min.z = boundingBox.minimum.z < min.z ? boundingBox.minimum.z : min.z;

    max.x = boundingBox.maximum.x > max.x ? boundingBox.maximum.x : max.x;
    max.y = boundingBox.maximum.y > max.y ? boundingBox.maximum.y : max.y;
    max.z = boundingBox.maximum.z > max.z ? boundingBox.maximum.z : max.z;
  });

  const size = max!.subtract(min!);

  const boundingInfo = new BoundingInfo(min!, max!);
  const bbCenterWorld = boundingInfo.boundingBox.centerWorld;

  // const m = MeshBuilder.CreateBox("bounds", { size: 1 }, scene);
  // m.scaling.copyFrom(size);
  // m.position.copyFrom(bbCenterWorld);
  // m.visibility = 0.1;

  console.log("Width: ", size.x);
  console.log("Height: ", size.y);
  console.log("Depth: ", size.z);
  console.log("Position: ", bbCenterWorld);
  meshes[0].position.subtractInPlace(bbCenterWorld);
};
