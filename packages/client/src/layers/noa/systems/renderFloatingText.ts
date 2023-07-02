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
export const renderFloatingTextAboveCoord = (coord: VoxelCoord, noa: Engine, text: string) => {
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

  const offsetX = textureLength / 2 - longestLineWidth / 2;
  textureContext.fillStyle = "#414141";
  textureContext.fillRect(offsetX, 0, backgroundWidth, backgroundHeight + backgroundPadding * 2);

  // Draw text
  textureContext.fillStyle = "white";
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const textWidth = textureContext.measureText(line).width;

    // we need to do i+1 for the y-axis, cause for some reason, the fonts are drawn from the bottom up
    textureContext.fillText(
      line,
      offsetX + backgroundWidth / 2 - textWidth / 2,
      fontHeight * (i + 1) + backgroundPadding / 2
    );
  }

  // Update the dynamic texture
  dynamicTexture.update();

  // Create a plane and apply the dynamic texture using MeshBuilder
  const plane = MeshBuilder.CreatePlane("plane", { width: 1, height: 1 }, scene);
  const material = new StandardMaterial("Mat", scene);
  material.diffuseTexture = dynamicTexture;
  plane.material = material;

  // Rotate plane to face camera
  plane.billboardMode = Mesh.BILLBOARDMODE_ALL;
  plane.position.set(
    coord.x + 0.5,
    // coord.x + backgroundWidth / (2 * textureLength) + 0.5,
    coord.y + 1,
    // coord.z + backgroundWidth / (2 * textureLength) + 0.5
    coord.z + 0.5
  );
  const isStatic = false; // this is false so it will turn to the player
  noa.rendering.addMeshToScene(plane, isStatic);
};
