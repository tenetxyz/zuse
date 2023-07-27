import * as BABYLON from "@babylonjs/core";
import type { Engine } from "noa-engine";
import { SCENE_COLOR, SKY_PLANE_COLOR } from "../setup/constants";

// the sky and cloud logic was taken and modified from VoxelSrv: https://github.com/VoxelSrv/voxelsrv/blob/master/src/lib/gameplay/sky.ts
const SKY_HEIGHT = 50;

export let cloudMesh: BABYLON.Mesh;
export let skyPlaneMesh: BABYLON.Mesh;

export function setupClouds(noa: Engine) {
  const scene = noa.rendering.getScene();
  cloudMesh = BABYLON.MeshBuilder.CreatePlane(
    "cloudMesh",
    {
      height: 500,
      width: 500,
    },
    scene
  );

  const cloudMat = new BABYLON.StandardMaterial("cloud", scene);

  const cloudTexture = new BABYLON.Texture(
    "./public/img/clouds.png",
    scene,
    true,
    true,
    BABYLON.Texture.NEAREST_SAMPLINGMODE
  );
  cloudTexture.hasAlpha = true;
  cloudTexture.vScale = 0.75;
  cloudTexture.uScale = 0.75;

  cloudMat.diffuseTexture = cloudTexture;
  cloudMat.opacityTexture = cloudTexture;
  cloudMat.backFaceCulling = false;
  cloudMat.emissiveColor = new BABYLON.Color3(1, 1, 1);

  cloudMesh.rotation.x = -Math.PI / 2;
  cloudMesh.material = cloudMat;

  noa.rendering.addMeshToScene(cloudMesh, false);

  let pos = [...noa.camera.getPosition()];

  const local: number[] = [];
  const update = () => {
    const [playerX, playerY, playerZ] = noa.ents.getPositionData(noa.playerEntity)!.position!;
    const [x, y, z] = noa.globalToLocal([playerX, playerY, playerZ], [0, 0, 0], local);

    cloudTexture.vOffset += 0.00001 + (pos[2] - noa.camera.getPosition()[2]) / 10000;
    cloudTexture.uOffset -= (pos[0] - noa.camera.getPosition()[0]) / 10000;
    pos = [...noa.camera.getPosition()];

    cloudMesh.position.copyFromFloats(x, y + SKY_HEIGHT - 5, z); // -5 so it shows up below the sky plane (i.e. in front of it)
  };

  noa.on("beforeRender", update);

  cloudMesh.onDisposeObservable.add(() => {
    noa.off("beforeRender", update);
  });
}

export function setupSky(noa: Engine) {
  const scene: BABYLON.Scene = noa.rendering.getScene();

  // change the color of the scene so when you look out, it blends with the color of the sky plane
  // https://doc.babylonjs.com/features/featuresDeepDive/environment/environment_introduction
  // I tried using a skybox instead to give color ot the lighter part of the sky, but
  // since the latest version of noa adds "shadows" on the faces of meshes that are away fro mthe light source
  // my skybox didn't have uniform color. This is why I am using clearColor instead
  scene.clearColor = new BABYLON.Color4(...SCENE_COLOR, 1);

  if (skyPlaneMesh != null && !skyPlaneMesh.isDisposed) {
    skyPlaneMesh.dispose();
  }

  // This plane is the darker part of the sky when you look up
  skyPlaneMesh = BABYLON.MeshBuilder.CreatePlane(
    "skyPlaneMesh",
    {
      height: 1.2e4, // The height and width of the plane determines how large the cloud texture is.
      width: 1.2e4, // Don't make these values too small or the clouds will not cover the entire sky
    },
    scene
  );

  const skyPlaneMat = new BABYLON.StandardMaterial("sky", scene);
  skyPlaneMat.backFaceCulling = false;
  skyPlaneMat.emissiveColor = new BABYLON.Color3(...SKY_PLANE_COLOR);
  skyPlaneMat.diffuseColor = skyPlaneMat.emissiveColor;

  skyPlaneMesh.infiniteDistance = true;
  skyPlaneMesh.renderingGroupId;
  skyPlaneMesh.material = skyPlaneMat;

  skyPlaneMesh.rotation.x = -Math.PI / 2;

  noa.rendering.addMeshToScene(skyPlaneMesh, false);

  const update = () => {
    let pos = noa.camera.getPosition();
    skyPlaneMesh.position.copyFromFloats(pos[0], pos[1] + SKY_HEIGHT, pos[2]);
  };

  noa.on("beforeRender", update);
  skyPlaneMesh.onDisposeObservable.add(() => {
    noa.off("beforeRender", update);
  });
}
