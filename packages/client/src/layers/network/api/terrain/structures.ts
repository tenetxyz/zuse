import { VoxelCoord } from "@latticexyz/utils";
import { VoxelTypeKeyToId } from "../../constants";
import { Structure } from "../../types";
import { STRUCTURE_CHUNK } from "./constants";

function getEmptyStructure(): Structure {
  return [
    [[], [], [], [], []],
    [[], [], [], [], []],
    [[], [], [], [], []],
    [[], [], [], [], []],
    [[], [], [], [], []],
  ];
}

function defineTree(): Structure {
  const s = getEmptyStructure();

  // Trunk
  s[3][0][3] = VoxelTypeKeyToId.Log;
  s[3][1][3] = VoxelTypeKeyToId.Log;
  s[3][2][3] = VoxelTypeKeyToId.Log;
  s[3][3][3] = VoxelTypeKeyToId.Log;

  // Leaves
  s[2][3][3] = VoxelTypeKeyToId.Leaves;
  s[3][3][2] = VoxelTypeKeyToId.Leaves;
  s[4][3][3] = VoxelTypeKeyToId.Leaves;
  s[3][3][4] = VoxelTypeKeyToId.Leaves;
  s[2][3][2] = VoxelTypeKeyToId.Leaves;
  s[4][3][4] = VoxelTypeKeyToId.Leaves;
  s[2][3][4] = VoxelTypeKeyToId.Leaves;
  s[4][3][2] = VoxelTypeKeyToId.Leaves;
  s[2][4][3] = VoxelTypeKeyToId.Leaves;
  s[3][4][2] = VoxelTypeKeyToId.Leaves;
  s[4][4][3] = VoxelTypeKeyToId.Leaves;
  s[3][4][4] = VoxelTypeKeyToId.Leaves;
  s[3][4][3] = VoxelTypeKeyToId.Leaves;

  return s;
}

function defineWoolTree(): Structure {
  const s = getEmptyStructure();

  // Trunk
  s[3][0][3] = VoxelTypeKeyToId.Log;
  s[3][1][3] = VoxelTypeKeyToId.Log;
  s[3][2][3] = VoxelTypeKeyToId.Log;
  s[3][3][3] = VoxelTypeKeyToId.Log;

  // Leaves
  s[2][2][3] = VoxelTypeKeyToId.Wool;
  s[3][2][2] = VoxelTypeKeyToId.Wool;
  s[4][2][3] = VoxelTypeKeyToId.Wool;
  s[3][2][4] = VoxelTypeKeyToId.Wool;
  s[2][3][3] = VoxelTypeKeyToId.Wool;
  s[3][3][2] = VoxelTypeKeyToId.Wool;
  s[4][3][3] = VoxelTypeKeyToId.Wool;
  s[3][3][4] = VoxelTypeKeyToId.Wool;
  s[2][3][2] = VoxelTypeKeyToId.Wool;
  s[4][3][4] = VoxelTypeKeyToId.Wool;
  s[2][3][4] = VoxelTypeKeyToId.Wool;
  s[4][3][2] = VoxelTypeKeyToId.Wool;
  s[2][4][3] = VoxelTypeKeyToId.Wool;
  s[3][4][2] = VoxelTypeKeyToId.Wool;
  s[4][4][3] = VoxelTypeKeyToId.Wool;
  s[3][4][4] = VoxelTypeKeyToId.Wool;
  s[3][4][3] = VoxelTypeKeyToId.Wool;

  return s;
}

export const Tree = defineTree();
export const WoolTree = defineWoolTree();

export function getStructureVoxel(
  structure: Structure,
  { x, y, z }: VoxelCoord
) {
  if (
    x < 0 ||
    y < 0 ||
    z < 0 ||
    x >= STRUCTURE_CHUNK ||
    y >= STRUCTURE_CHUNK ||
    z >= STRUCTURE_CHUNK
  )
    return undefined;
  return structure[x][y][z];
}
