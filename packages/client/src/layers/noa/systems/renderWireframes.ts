import {
  Color3,
  Color4,
  CreateBox,
  Mesh,
  MeshBuilder,
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
export const renderChunkyWireframe = (
  coord1: VoxelCoord,
  coord2: VoxelCoord,
  noa: Engine
) => {
  const scene = noa.rendering.getScene();

  // we need to add one to the max values because each coord is on the lowerSouthWest corner of each voxel. Adding one will make the point the upperNorthEast corner of each voxel
  const minX = Math.min(coord1.x, coord2.x);
  const maxX = Math.max(coord1.x, coord2.x) + 1;
  const minY = Math.min(coord1.y, coord2.y);
  const maxY = Math.max(coord1.y, coord2.y) + 1;
  const minZ = Math.min(coord1.z, coord2.z);
  const maxZ = Math.max(coord1.z, coord2.z) + 1;

  // given these points, create an array of pairs of adjacent voxels
  const adjacentVoxels = [
    [newVC(minX, minY, minZ), newVC(minX, minY, maxZ)],
    [newVC(minX, minY, minZ), newVC(minX, maxY, minZ)],
    [newVC(minX, minY, minZ), newVC(maxX, minY, minZ)],
    [newVC(minX, minY, maxZ), newVC(minX, maxY, maxZ)],
    [newVC(minX, minY, maxZ), newVC(maxX, minY, maxZ)],
    [newVC(minX, maxY, minZ), newVC(minX, maxY, maxZ)],
    [newVC(minX, maxY, minZ), newVC(maxX, maxY, minZ)],
    [newVC(minX, maxY, maxZ), newVC(maxX, maxY, maxZ)],
    [newVC(maxX, minY, minZ), newVC(maxX, minY, maxZ)],
    [newVC(maxX, minY, minZ), newVC(maxX, maxY, minZ)],
    [newVC(maxX, minY, maxZ), newVC(maxX, maxY, maxZ)],
    [newVC(maxX, maxY, minZ), newVC(maxX, maxY, maxZ)],
  ];
  const edgeMeshes = adjacentVoxels.map((pair) =>
    getEdgeMesh(pair[0], pair[1], scene)
  );

  // now draw a cube at each corner
  const corners = [
    newVC(minX, minY, minZ),
    newVC(minX, minY, maxZ),
    newVC(minX, maxY, minZ),
    newVC(minX, maxY, maxZ),
    newVC(maxX, minY, minZ),
    newVC(maxX, minY, maxZ),
    newVC(maxX, maxY, minZ),
    newVC(maxX, maxY, maxZ),
  ];

  const disposeOriginalMeshesAfterCreatingCombinedMesh = true;
  const cornerMeshes = corners.map((corner) => getCornerMesh(corner, scene));
  const chunkyWireframe = Mesh.MergeMeshes(
    edgeMeshes.concat(cornerMeshes),
    disposeOriginalMeshesAfterCreatingCombinedMesh
  );
  noa.rendering.addMeshToScene(chunkyWireframe);
};

const getCornerMesh = (corner: VoxelCoord, scene: Scene): Mesh => {
  const box = CreateBox("", { size: outlineThickness }, scene);
  const material = new StandardMaterial("material", scene);
  material.emissiveColor = new Color3(1, 1, 1);
  box.material = material;

  box.position.set(corner.x, corner.y, corner.z);
  return box;
};

const outlineThickness = 0.05;

function adjustDimensionSize(dimension: number) {
  return dimension === 0
    ? dimension + outlineThickness
    : dimension - outlineThickness;
}
const getEdgeMesh = (
  coord1: VoxelCoord,
  coord2: VoxelCoord,
  scene: Scene
): Mesh => {
  // Calculate the dimensions of the rectangular prism
  let width = Math.abs(coord1.x - coord2.x);
  let height = Math.abs(coord1.y - coord2.y);
  let depth = Math.abs(coord1.z - coord2.z);
  width = adjustDimensionSize(width);
  height = adjustDimensionSize(height);
  depth = adjustDimensionSize(depth);
  const prism = MeshBuilder.CreateBox(
    "prism",
    { width: width, height: height, depth: depth },
    scene
  );
  // Position the prism between the two points
  prism.position.set(
    (coord1.x + coord2.x) / 2,
    (coord1.y + coord2.y) / 2,
    (coord1.z + coord2.z) / 2
  );

  const material = new StandardMaterial("material", scene);
  material.emissiveColor = new Color3(1, 1, 1);
  prism.material = material;
  return prism;
};

const renderBoxWireframe = (x: number, y: number, z: number, noa: Engine) => {
  renderLine(
    [
      new Vector3(x, y, z),
      new Vector3(x + 1, y, z),
      new Vector3(x + 1, y + 1, z),
      new Vector3(x, y + 1, z),
      new Vector3(x, y, z),
    ],
    noa
  );
  renderLine(
    [
      new Vector3(x, y, z + 1),
      new Vector3(x + 1, y, z + 1),
      new Vector3(x + 1, y + 1, z + 1),
      new Vector3(x, y + 1, z + 1),
      new Vector3(x, y, z + 1),
    ],
    noa
  );
  renderLine([new Vector3(x, y, z), new Vector3(x, y, z + 1)], noa);
  renderLine([new Vector3(x + 1, y, z), new Vector3(x + 1, y, z + 1)], noa);
  renderLine(
    [new Vector3(x + 1, y + 1, z), new Vector3(x + 1, y + 1, z + 1)],
    noa
  );
  renderLine([new Vector3(x, y + 1, z), new Vector3(x, y + 1, z + 1)], noa);
};
const renderLine = (linePoints: Vector3[], noa: Engine) => {
  const scene = noa.rendering.getScene();
  const line = MeshBuilder.CreateLines("line", { points: linePoints }, scene);
  const material = new StandardMaterial("material", scene);
  material.emissiveColor = new Color3(1, 1, 1);
  line.material = material;
  noa.rendering.addMeshToScene(line);
};
