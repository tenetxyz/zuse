import { DynamicTexture, Mesh, MeshBuilder, StandardMaterial } from "@babylonjs/core";
import { VoxelCoord } from "@latticexyz/utils";
import { Engine } from "noa-engine";

const textureLength = 1024; // this means: that one block is subdivided into 1024 subpixels

// These constants are for us to predict the size of the background
// It's important for us to use a monospace font so we can simply multiply the width of a character by the number of characters
const fontSize = 100;
const charHeight = fontSize;
const charWidth = 70; // I guessed this number. It seems to work well

const backgroundPadding = 30;

// Create the dynamic texture
export const renderFloatingTextAboveCoord = (coord: VoxelCoord, noa: Engine, text: string) => {
  const { longestLine, numLines, lines } = determineTextSize(text);
  const scene = noa.rendering.getScene();
  const dynamicTexture = new DynamicTexture(
    "dynamic texture",
    { width: textureLength, height: textureLength },
    scene,
    true
  );
  dynamicTexture.hasAlpha = true;

  // 2) calculate the size of the background
  const textureContext = dynamicTexture.getContext();
  textureContext.font = `bold ${fontSize}px monospace`;
  const longestLineWidth = textureContext.measureText(longestLine).width;
  const totalLineHeight = numLines * charHeight;

  const backgroundWidth = longestLineWidth + backgroundPadding * 2;
  const backgroundHeight = totalLineHeight + backgroundPadding * 2;

  // 3) Draw background
  // Since the pivot point of the plane is in the middle of the textureLength,
  // we need to offset the text so that the middle of the text is on the pivot point (only the x-axis is offset rn)
  const offsetX = textureLength / 2 - longestLineWidth / 2;
  textureContext.fillStyle = "#414141";
  textureContext.fillRect(offsetX, 0, backgroundWidth, backgroundHeight);

  // 4) Draw each line of text
  textureContext.fillStyle = "white";
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const textWidth = textureContext.measureText(line).width;

    // we need to do i+1 for the y-axis, cause for some reason, the fonts are drawn from the bottom up
    textureContext.fillText(
      line,
      offsetX + backgroundWidth / 2 - textWidth / 2,
      charHeight * (i + 1) + backgroundPadding / 2
    );
  }
  dynamicTexture.update();

  // 5) Write the texture to the plane
  // Create a plane and apply the dynamic texture using MeshBuilder
  const plane = MeshBuilder.CreatePlane("plane", { width: 1, height: 1 }, scene);
  const material = new StandardMaterial("Mat", scene);
  material.diffuseTexture = dynamicTexture;
  plane.material = material;

  plane.billboardMode = Mesh.BILLBOARDMODE_ALL; // Rotate plane to face camera

  // add the plane to the scene in the right spot
  plane.position.set(coord.x + 0.5, coord.y + 1, coord.z + 0.5);
  const isStatic = false; // this is false so it the text will turn to the player
  noa.rendering.addMeshToScene(plane, isStatic);
};

export const determineTextSize = (text: string) => {
  const lines = text.split("\n");
  const numLines = lines.length;
  const longestLine = lines.reduce((longestLine, line) => {
    if (line.length > longestLine.length) {
      return line;
    }
    return longestLine;
  });
  return { longestLine, numLines: lines.length, lines };
};
