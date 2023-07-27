import * as BABYLON from "@babylonjs/core";
import { Engine } from "noa-engine";
import { CHUNK_RENDER_DISTANCE, CHUNK_SIZE, SKY_COLOR, FOG_COLOR } from "../setup/constants";

export function setupScene(noa: Engine) {
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  //@ts-ignore
  const scene = noa.rendering.getScene();
  scene.fogMode = BABYLON.Scene.FOGMODE_LINEAR;
  scene.fogStart = 100;
  scene.fogEnd = 1000;
  scene.fogColor = new BABYLON.Color3(...FOG_COLOR);
  scene.fogDensity = 0.000005;
  const colorGrading = new BABYLON.Texture("./assets/textures/lut/LUT_Night2.png", scene, true, false);
  colorGrading.level = 0;
  colorGrading.wrapU = BABYLON.Texture.CLAMP_ADDRESSMODE;
  colorGrading.wrapV = BABYLON.Texture.CLAMP_ADDRESSMODE;
  scene.imageProcessingConfiguration.colorGradingWithGreenDepth = false;
  scene.imageProcessingConfiguration.colorGradingEnabled = true;
  scene.imageProcessingConfiguration.colorGradingTexture = colorGrading;
  // Color Curves
  const postProcess = new BABYLON.ImageProcessingPostProcess("processing", 1.0, noa.rendering.camera);
  const curve = new BABYLON.ColorCurves();
  curve.globalSaturation = 100; // CANDY!
  postProcess.colorCurves = curve;
  postProcess.colorCurvesEnabled = true;
  // Glow
  const glow = new BABYLON.GlowLayer("glow", scene, {
    mainTextureFixedSize: 512,
    blurKernelSize: 256,
  });
  glow.intensity = 0.1;
  return { colorGrading, postProcess, glow };
}
