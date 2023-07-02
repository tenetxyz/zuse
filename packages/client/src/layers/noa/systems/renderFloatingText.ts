import {
  Color3,
  Color4,
  CreateBox,
  DynamicTexture,
  Mesh,
  MeshBuilder,
  Nullable,
  StandardMaterial,
  Vector3,
} from "@babylonjs/core";
import { VoxelCoord } from "@latticexyz/utils";
import { Engine } from "noa-engine";
import { Scene } from "@babylonjs/core/scene";

const newVC = (x: number, y: number, z: number): VoxelCoord => ({
  x,
  y,
  z,
});

// Create the dynamic texture
const dynamicTexture = new DynamicTexture("dynamic texture", 512, scene, true);
dynamicTexture.hasAlpha = true;

// Draw text on the dynamic texture
const textureContext = dynamicTexture.getContext();
textureContext.font = "bold 44px monospace";
textureContext.fillStyle = "white";

export const renderFloatingText = (coord1: VoxelCoord, noa: Engine, text: string) => {
  const scene = noa.rendering.getScene();
  textureContext.fillText("Hello World", 256, 256);

  // Update the dynamic texture
  dynamicTexture.update();

  // Create a plane and apply the dynamic texture using MeshBuilder
  const plane = MeshBuilder.CreatePlane("plane", {}, scene);
  const material = new StandardMaterial("Mat", scene);
  material.diffuseTexture = dynamicTexture;
  plane.material = material;

  // Rotate plane to face camera
  plane.billboardMode = Mesh.BILLBOARDMODE_ALL;
  const isStatic = true;
  noa.rendering.addMeshToScene(plane, isStatic);
};
