import { Color3, MeshBuilder, Scene, StandardMaterial, Texture } from "@babylonjs/core";
import * as BABYLON from "@babylonjs/core";
import type { Engine } from "noa-engine";
import { FOG_COLOR, SKY_COLOR } from "../setup/constants";
/*
 * Setups clouds in a hacky way
 */
const CLOUD_HEIGHT = 90.5;
const SKY_HEIGHT = 50;

export function oldSetupClouds(noa: Engine) {
  // Parameters
  const size = 16;
  const widthNb = 40;
  const heightNb = 40;
  const numberOfParticles = widthNb * heightNb;

  const scene = noa.rendering.getScene();
  const mat = new BABYLON.StandardMaterial("mat1", scene);
  const cloudTexture = new BABYLON.Texture(
    "./assets/textures/environment/clouds.png",
    scene,
    true,
    true,
    Texture.NEAREST_SAMPLINGMODE
  );
  mat.diffuseTexture = cloudTexture;
  mat.diffuseTexture.hasAlpha = true;
  mat.specularColor = new BABYLON.Color3(0.2, 0.2, 0.2);
  mat.backFaceCulling = false;
  mat.freeze();

  const faceUV = new Array(6);

  for (let i = 0; i < 6; i++) {
    faceUV[i] = new BABYLON.Vector4(0, 0, 0, 0);
  }

  const options = {
    size: size,
    faceUV: faceUV,
  };

  const model = BABYLON.MeshBuilder.CreateBox("box", options, scene);

  // SPS
  const sps = new BABYLON.SolidParticleSystem("sps", scene);
  sps.addShape(model, numberOfParticles);
  model.dispose();
  const s = sps.buildMesh();
  s.material = mat;

  // Tmp internal vars
  sps.vars.target = BABYLON.Vector3.Zero();
  sps.vars.tmp = BABYLON.Vector3.Zero();
  sps.vars.totalWidth = size * widthNb;
  sps.vars.totalHeight = size * heightNb;
  sps.vars.shiftx = -sps.vars.totalWidth / 2;
  sps.vars.shifty = -sps.vars.totalHeight / 2;

  // SPS initializator : just set the particle along a wall
  let p = 0;
  for (let j = 0; j < heightNb; j++) {
    for (let i = 0; i < widthNb; i++) {
      // let's position the quads on a grid
      sps.particles[p].position.x = i * size + sps.vars.shiftx;
      sps.particles[p].position.y = j * size + sps.vars.shifty;
      sps.particles[p].position.z = 0;

      // let's set the texture per quad
      sps.particles[p].uvs.x = (i * size) / sps.vars.totalWidth;
      sps.particles[p].uvs.y = (j * size) / sps.vars.totalHeight;
      sps.particles[p].uvs.z = ((i + 1) * size) / sps.vars.totalWidth;
      sps.particles[p].uvs.w = ((j + 1) * size) / sps.vars.totalHeight;

      // increment the particle index
      p++;
    }
  }

  const pl = new BABYLON.DirectionalLight("pl", new BABYLON.Vector3(0, 1, 0), scene);
  pl.intensity = 0.5;
  pl.diffuse = new BABYLON.Color3(1, 1, 1);
  pl.specular = BABYLON.Color3.Black();

  // Init sps
  sps.setParticles(); // set them
  sps.refreshVisibleSize(); // compute the bounding box
  sps.computeParticleColor = false; // the colors won't change
  sps.computeParticleTexture = false; // nor the texture now
  s.rotation.x = -Math.PI / 2;

  noa.rendering.addMeshToScene(s, false);

  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
  const [playerX, , playerZ] = noa.ents.getPositionData(noa.playerEntity)!.position!;
  const cloudCenter = [playerX, playerZ];
  let currentRadian = 0;

  const update = () => {
    const local: number[] = [];
    const wrappedRadian = currentRadian - Math.floor(currentRadian / (Math.PI * 2)) * (Math.PI * 2);
    const cloudPosition = [
      cloudCenter[0] + Math.sin(wrappedRadian) * 100,
      cloudCenter[1] + Math.cos(wrappedRadian) * 100,
    ];
    currentRadian += 0.0001;
    const [x, y, z] = noa.globalToLocal([cloudPosition[0], CLOUD_HEIGHT, cloudPosition[1]], [0, 0, 0], local);
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const [currentPlayerX, , currentPlayerZ] = noa.ents.getPositionData(noa.playerEntity)!.position!;
    s.position.copyFromFloats(x, y, z);
    // move clouds towards player
    const diffX = currentPlayerX - cloudCenter[0];
    const diffZ = currentPlayerZ - cloudCenter[1];
    const distance = Math.sqrt(diffX ** 2 + diffZ ** 2);
    const speedVector = [
      0.00001 * Math.sign(diffX) * Math.sqrt(distance),
      0.00001 * Math.sign(diffZ) * Math.sqrt(distance),
    ];
    cloudCenter[0] += speedVector[0];
    cloudCenter[1] += speedVector[1];
  };

  noa.on("beforeRender", update);

  s.onDisposeObservable.add(() => {
    noa.off("beforeRender", update);
  });
}

/*
 * Setups sky color
 */

export function oldSetupSky(noa: Engine) {
  const scene: Scene = noa.rendering.getScene();
  const skyMesh = MeshBuilder.CreatePlane(
    "skyMesh",
    {
      height: 1.2e4,
      width: 1.2e4,
    },
    scene
  );
  const skyBox = MeshBuilder.CreateBox(
    "skyMesh",
    {
      height: 1.2e4,
      width: 1.2e4,
      depth: 1000,
    },
    scene
  );

  const skyMat = new StandardMaterial("sky", scene);
  const skyBoxMat = new StandardMaterial("skyBox", scene);
  skyMat.backFaceCulling = false;
  skyMat.emissiveColor = new Color3(0.2, 0.3, 0.7);
  skyMat.diffuseColor = new Color3(0.2, 0.3, 0.7);
  skyBoxMat.backFaceCulling = false;
  skyBoxMat.diffuseColor = new Color3(...SKY_COLOR);

  skyMesh.renderingGroupId = -1;
  skyMesh.material = skyMat;
  skyMesh.applyFog = true;

  skyBox.renderingGroupId = -1;
  skyBox.material = skyMat;
  skyBox.applyFog = true;

  skyMesh.rotation.x = -Math.PI / 2;

  noa.rendering.addMeshToScene(skyMesh, false);
  noa.rendering.addMeshToScene(skyBox, false);

  const update = () => {
    const local: number[] = [];
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const [playerX, playerY, playerZ] = noa.ents.getPositionData(noa.playerEntity)!.position!;
    const [x, y, z] = noa.globalToLocal([playerX, playerY, playerZ], [0, 0, 0], local);
    skyMesh.position.copyFromFloats(x, y + SKY_HEIGHT, z);
    skyBox.position.copyFromFloats(x, y + SKY_HEIGHT, z);
  };

  noa.on("beforeRender", update);

  skyMesh.onDisposeObservable.add(() => {
    noa.off("beforeRender", update);
  });
}

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

  // cloudMesh.setPositionWithLocalVector(new BABYLON.Vector3(0, 0, 200));

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

    cloudMesh.position.copyFromFloats(x, y + SKY_HEIGHT - 5, z); // -1 so it shows up in front of the sky plane
    // cloudMesh.setPositionWithLocalVector(new BABYLON.Vector3(0, SKY_HEIGHT, 200));
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
  skyMat.emissiveColor = new BABYLON.Color3(...SKY_COLOR);
  skyMat.diffuseColor = skyMat.emissiveColor;

  skyMesh.infiniteDistance = true;
  skyMesh.renderingGroupId;
  skyMesh.material = skyMat;

  skyMesh.rotation.x = -Math.PI / 2;

  noa.rendering.addMeshToScene(skyMesh, false);
  const SCENE_COLOR = [0.65, 0.75, 0.85];
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
