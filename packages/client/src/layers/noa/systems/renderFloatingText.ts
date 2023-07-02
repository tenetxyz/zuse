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

export const determineTextSize = (text: string) => {
  const lines = text.split("\n");
  const longestLine = lines.reduce((longestLine, line) => {
    if (line.length > longestLine.length) {
      return line;
    }
    return longestLine;
  });
  return { longestLine, numLines: lines.length };
};

const textureLength = 1024;
const fontSize = 100;
const fontHeight = fontSize;
const fontWidth = 70;
const backgroundPadding = 30;

// Create the dynamic texture
export const renderFloatingTextAboveCoord = (coord1: VoxelCoord, noa: Engine, text: string) => {
  const { longestLine, numLines } = determineTextSize(text);
  const lines = text.split("\n");

  const scene = noa.rendering.getScene();
  const dynamicTexture = new DynamicTexture(
    "dynamic texture",
    { width: textureLength, height: textureLength },
    scene,
    true
  );
  dynamicTexture.hasAlpha = true;

  // Draw text on the dynamic texture
  const textureContext = dynamicTexture.getContext();
  textureContext.font = `bold ${fontSize}px monospace`;
  const longestLineWidth = textureContext.measureText(longestLine).width;
  const backgroundHeight = numLines * fontHeight;

  const backgroundWidth = longestLineWidth + backgroundPadding * 2;
  textureContext.fillStyle = "#414141";
  textureContext.fillRect(0, 0, backgroundWidth, backgroundHeight + backgroundPadding * 2);

  // Draw text
  textureContext.fillStyle = "white";
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const textWidth = textureContext.measureText(line).width;
    textureContext.fillText(line, backgroundWidth / 2 - textWidth / 2, fontHeight * (i + 1) + backgroundPadding / 2);
  }

  // Update the dynamic texture
  dynamicTexture.update();

  // Create a plane and apply the dynamic texture using MeshBuilder
  const plane = MeshBuilder.CreatePlane("plane", {}, scene);
  const material = new StandardMaterial("Mat", scene);
  material.diffuseTexture = dynamicTexture;
  plane.material = material;

  // Rotate plane to face camera
  plane.billboardMode = Mesh.BILLBOARDMODE_ALL;
  plane.position.set(
    // coord1.x + 1 - backgroundWidth / (2 * textureLength),
    coord1.x + 0.5,
    coord1.y + 1.5,
    // coord1.z + 1 - backgroundWidth / (2 * textureLength)
    coord1.z + 0.5
  );
  const isStatic = false; // false so it will turn to the player
  noa.rendering.addMeshToScene(plane, isStatic);
};
