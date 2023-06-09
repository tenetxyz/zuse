import {
  Color3,
  MeshBuilder,
  StandardMaterial,
  Vector3,
} from "@babylonjs/core";

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
  material.emissiveColor = new Color3(1, 1, 1); // Red color
  line.material = material;
  noa.rendering.addMeshToScene(line);
};
