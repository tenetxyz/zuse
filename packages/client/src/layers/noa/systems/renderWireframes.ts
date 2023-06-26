import { Color3, Color4, CreateBox, Mesh, MeshBuilder, Nullable, StandardMaterial, Vector3 } from "@babylonjs/core";
import { VoxelCoord } from "@latticexyz/utils";
import { Engine } from "noa-engine";
import { Scene } from "@babylonjs/core/scene";

const newVC = (x: number, y: number, z: number): VoxelCoord => ({
  x,
  y,
  z,
});
// renders a wireframe around the cuboid defined by these two points.
// it's chunky because the edges have thickness
// how it works:
// 1) creates the 12 edge meshes. These are the edges of the cuboid
// 2) combine all of the meshes into one mesh
// 3) render this final mesh
export const renderChunkyWireframe = (
  coord1: VoxelCoord,
  coord2: VoxelCoord,
  noa: Engine,
  emissiveColor: Color3,
  wireframeThickness: number
): Nullable<Mesh> => {
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
    getEdgeMesh(scene, pair[0], pair[1], emissiveColor, wireframeThickness)
  );

  const disposeOriginalMeshesAfterCreatingCombinedMesh = true;
  const chunkyWireframeMesh = Mesh.MergeMeshes(edgeMeshes, disposeOriginalMeshesAfterCreatingCombinedMesh);
  const isStatic = false; // if we set this to true, the mesh will not be rendered if the center of the cuboid is NOT in view.
  // This is confusing when the corner of the cuboid is still visible, but the center is not, so the wireframe is not rendered
  noa.rendering.addMeshToScene(chunkyWireframeMesh, isStatic);
  return chunkyWireframeMesh;
};

// renders an edge between these two points for the wireframe
// this function assumes that the two coords differ by only one dimension
// this edge will run through the entire length of the dimension that they differ in
const getEdgeMesh = (
  scene: Scene,
  coord1: VoxelCoord,
  coord2: VoxelCoord,
  emissiveColor: Color3,
  wireframeThickness: number
): Mesh => {
  // Calculate the dimensions of the rectangular prism
  let width = Math.abs(coord1.x - coord2.x);
  let height = Math.abs(coord1.y - coord2.y);
  let depth = Math.abs(coord1.z - coord2.z);
  width = width + wireframeThickness;
  height = height + wireframeThickness;
  depth = depth + wireframeThickness;
  const prism = MeshBuilder.CreateBox("prism", { width: width, height: height, depth: depth }, scene);
  // Position the prism between the two points
  prism.position.set((coord1.x + coord2.x) / 2, (coord1.y + coord2.y) / 2, (coord1.z + coord2.z) / 2);

  const material = new StandardMaterial("material", scene);
  material.emissiveColor = emissiveColor;
  prism.material = material;
  return prism;
};
