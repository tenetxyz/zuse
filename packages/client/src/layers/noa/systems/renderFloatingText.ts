import { DynamicTexture, ICanvasRenderingContext, Mesh, MeshBuilder, StandardMaterial } from "@babylonjs/core";
import { VoxelCoord } from "@latticexyz/utils";
import { Engine } from "noa-engine";

const textureLength = 256 * 4; // this means: that one block is subdivided into 1024 subpixels

// These constants are for us to predict the size of the background
// It's important for us to use a monospace font so we can simply multiply the width of a character by the number of characters
const fontSize = 25 * 3;
const charHeight = fontSize;

const backgroundPadding = 7 * 4;

// Create the dynamic texture
export const renderFloatingTextAboveCoord = (coord: VoxelCoord, noa: Engine, text: string) => {
  const { longestLine, numLines, lines } = determineTextSize(text);
  const scene = noa.rendering.getScene();
  const scaleFactor = 2;
  const textureLengthScaled = textureLength * scaleFactor;
  const fontSizeScaled = fontSize * scaleFactor;
  const dynamicTexture = createDynamicTexture(scene, textureLengthScaled);

  const textureContext = dynamicTexture.getContext();
  textureContext.font = `bold ${fontSizeScaled}px monospace`;

  const longestLineWidth = textureContext.measureText(longestLine).width;
  const totalLineHeight = numLines * charHeight * scaleFactor;

  const backgroundWidth = longestLineWidth + backgroundPadding * scaleFactor * 2;
  const backgroundHeight = totalLineHeight + backgroundPadding * scaleFactor * 2;

  // Since the pivot point of the plane is in the middle of the textureLength,
  // we need to offset the text so that the middle of the text is on the pivot point (only the x-axis is offset rn)
  const offsetX = textureLengthScaled / 2 - longestLineWidth / 2;

  drawBackground(textureContext, offsetX, backgroundWidth, backgroundHeight);
  drawText(textureContext, lines, offsetX, backgroundWidth, fontSizeScaled, scaleFactor);

  dynamicTexture.update();

  addTextToScene(scene, dynamicTexture, coord, noa);
};

const createDynamicTexture = (scene: any, textureLengthScaled: number) => {
  const dynamicTexture = new DynamicTexture(
    "dynamic texture",
    { width: textureLengthScaled, height: textureLengthScaled },
    scene,
    true
  );
  dynamicTexture.hasAlpha = true;
  return dynamicTexture;
};

const drawBackground = (
  textureContext: ICanvasRenderingContext,
  offsetX: number,
  backgroundWidth: number,
  backgroundHeight: number
) => {
  textureContext.fillStyle = "#414141";
  textureContext.fillRect(offsetX, 0, backgroundWidth, backgroundHeight);
};

const drawText = (
  textureContext: ICanvasRenderingContext,
  lines: string[],
  offsetX: number,
  backgroundWidth: number,
  fontSizeScaled: number,
  scaleFactor: number
) => {
  textureContext.fillStyle = "white";
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const textWidth = textureContext.measureText(line).width;
    textureContext.fillText(
      line,
      offsetX + backgroundWidth / 2 - textWidth / 2,
      // we need to do i+1 for the y-axis, cause for some reason, the fonts are drawn from the bottom up
      charHeight * scaleFactor * (i + 1) + (backgroundPadding * scaleFactor) / 2
    );
  }
};

const addTextToScene = (scene: any, dynamicTexture: DynamicTexture, coord: VoxelCoord, noa: any) => {
  const plane = MeshBuilder.CreatePlane("plane", { width: 1, height: 1 }, scene);
  const material = new StandardMaterial("Mat", scene);
  material.diffuseTexture = dynamicTexture;
  plane.material = material;

  plane.billboardMode = Mesh.BILLBOARDMODE_ALL; // Rotate plane to face camera

  plane.position.set(coord.x + 0.5, coord.y + 1, coord.z + 0.5);
  const isStatic = false; // this is false so it the text will turn to the player
  noa.rendering.addMeshToScene(plane, isStatic);
};

export const determineTextSize = (text: string) => {
  const lines = text.split("\n");
  const longestLine = lines.reduce((longestLine, line) => {
    if (line.length > longestLine.length) {
      return line;
    }
    return longestLine;
  });
  return { longestLine, numLines: lines.length, lines };
};
