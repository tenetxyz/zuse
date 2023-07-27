import { Color3, MeshBuilder, Scene, StandardMaterial, Texture } from "@babylonjs/core";
import * as BABYLON from "@babylonjs/core";
import type { Engine } from "noa-engine";
import { SCENE_COLOR, SKY_PLANE_COLOR } from "../setup/constants";

const SKY_HEIGHT = 50;

export let cloudMesh: BABYLON.Mesh;
export let skyMesh: BABYLON.Mesh;

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
  scene.clearColor = new BABYLON.Color4(0.8, 0.9, 1, 1);
  if (skyMesh != null && !skyMesh.isDisposed) {
    skyMesh.dispose();
  }
  skyMesh = BABYLON.MeshBuilder.CreatePlane(
    "skyMesh",
    {
      height: 1.2e4,
      width: 1.2e4,
    },
    scene
  );

  const skyMat = new BABYLON.StandardMaterial("sky", scene);
  skyMat.backFaceCulling = false;
  skyMat.emissiveColor = new BABYLON.Color3(...SKY_PLANE_COLOR);
  skyMat.diffuseColor = skyMat.emissiveColor;

  skyMesh.infiniteDistance = true;
  skyMesh.renderingGroupId;
  skyMesh.material = skyMat;

  skyMesh.rotation.x = -Math.PI / 2;

  noa.rendering.addMeshToScene(skyMesh, false);
  // https://doc.babylonjs.com/features/featuresDeepDive/environment/environment_introduction
  scene.clearColor = new BABYLON.Color4(...SCENE_COLOR, 1);

  // skyMesh.setPositionWithLocalVector(new BABYLON.Vector3(0, 0, 500));

  const update = () => {
    const local: number[] = [];
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const [playerX, playerY, playerZ] = noa.ents.getPositionData(noa.playerEntity)!.position!;
    const [x, y, z] = noa.globalToLocal([playerX, playerY, playerZ], [0, 0, 0], local);
    skyMesh.position.copyFromFloats(x, playerY + SKY_HEIGHT, z);
  };

  noa.on("beforeRender", update);
  skyMesh.onDisposeObservable.add(() => {
    noa.off("beforeRender", update);
  });
}
