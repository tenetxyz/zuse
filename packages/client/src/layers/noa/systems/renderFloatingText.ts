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
  return { width: longestLine.length, height: lines.length };
};

// Create the dynamic texture
export const renderFloatingTextAboveCoord = (coord1: VoxelCoord, noa: Engine, text: string) => {
  const { width, height } = determineTextSize(text);

  const scene = noa.rendering.getScene();
  // 512 is the side length of the texture
  const dynamicTexture = new DynamicTexture("dynamic texture", { width: 1024, height: 1024 }, scene, true);
  dynamicTexture.hasAlpha = true;

  // Draw text on the dynamic texture
  const textureContext = dynamicTexture.getContext();
  const fontSize = 100;
  const backgroundPadding = 30;
  textureContext.font = `bold ${100}px monospace`;
  const textWidth = textureContext.measureText(text).width;
  const textHeight = height * fontSize;

  textureContext.fillStyle = "grey";
  textureContext.fillRect(
    0,
    -backgroundPadding - 10, // since fonts tend to sink lower than higher, this makes the text feel more vertically centered
    textWidth + backgroundPadding,
    textHeight + fontSize / 2 + backgroundPadding
  );

  textureContext.fillStyle = "white";
  textureContext.fillText(text, 0, textHeight);

  // Update the dynamic texture
  dynamicTexture.update();

  // Create a plane and apply the dynamic texture using MeshBuilder
  const plane = MeshBuilder.CreatePlane("plane", {}, scene);
  const material = new StandardMaterial("Mat", scene);
  material.diffuseTexture = dynamicTexture;
  plane.material = material;

  // Rotate plane to face camera
  plane.billboardMode = Mesh.BILLBOARDMODE_ALL;
  plane.position.set(coord1.x + 1.5 - textWidth / 1024, coord1.y + 1.5, coord1.z + 1.5 - textWidth / 1024);
  const isStatic = false; // false so it will turn to the player
  noa.rendering.addMeshToScene(plane, isStatic);
};
