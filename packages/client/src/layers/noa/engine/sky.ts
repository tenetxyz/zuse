import { Color3, MeshBuilder, Scene, StandardMaterial, Texture } from "@babylonjs/core";
import * as BABYLON from "@babylonjs/core";
import type { Engine } from "noa-engine";
import { SCENE_COLOR, SKY_PLANE_COLOR } from "../setup/constants";

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

  const playerMeshState = noa.ents.getState(noa.playerEntity, noa.ents.names.mesh);
  if (playerMeshState != undefined) {
    cloudMesh.setParent(playerMeshState.mesh);
  }
  const update = () => {
    const local: number[] = [];

    // cloudMesh.setPositionWithLocalVector(new BABYLON.Vector3(0, 0, 250 - noa.camera.getPosition()[1]));
    const [playerX, playerY, playerZ] = noa.ents.getPositionData(noa.playerEntity)!.position!;
    const [x, y, z] = noa.globalToLocal([playerX, playerY, playerZ], [0, 0, 0], local);

    cloudTexture.vOffset += 0.00001 + (pos[2] - noa.camera.getPosition()[2]) / 10000;
    cloudTexture.uOffset -= (pos[0] - noa.camera.getPosition()[0]) / 10000;
    pos = [...noa.camera.getPosition()];

    cloudMesh.position.copyFromFloats(x, y + SKY_HEIGHT - 5, z); // -5 so it shows up in front of the sky plane
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
      height: 1.2e4,
      width: 1.2e4,
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

  // skyMesh.setPositionWithLocalVector(new BABYLON.Vector3(0, 0, 500));

  const update = () => {
    const local: number[] = [];
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const [playerX, playerY, playerZ] = noa.ents.getPositionData(noa.playerEntity)!.position!;
    const [x, y, z] = noa.globalToLocal([playerX, playerY, playerZ], [0, 0, 0], local);
    skyPlaneMesh.position.copyFromFloats(x, playerY + SKY_HEIGHT, z);
  };

  noa.on("beforeRender", update);
  skyPlaneMesh.onDisposeObservable.add(() => {
    noa.off("beforeRender", update);
  });
}
