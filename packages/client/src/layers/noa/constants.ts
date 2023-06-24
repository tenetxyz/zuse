import { VoxelCoord } from "@latticexyz/utils";
import { VoxelTypeKey } from "../network/constants";
import { NoaVoxelDef, NoaBlockType } from "./types";

export const CRAFTING_SIDE = 3;
export const SPAWN_POINT: VoxelCoord = { x: -1543, y: 11, z: -808 };
export const CRAFTING_SIZE = CRAFTING_SIDE * CRAFTING_SIDE;
export const EMPTY_CRAFTING_TABLE = [...new Array(CRAFTING_SIZE)].map(() => -1);
export const MINING_DURATION = 300;
export const FAST_MINING_DURATION = 200;

export const Textures = {
  Grass: "./assets/voxels/4-Grass_block-top.png",
  GrassSide: "./assets/voxels/4-Grass_block-side.png",
  GrassBottom: "./assets/voxels/4-Grass_block-bottom.png",
  Dirt: "https://bafkreibzraiuk6hgngtfczn57sivuqf3nv77twi6g3ftas2umjnbf6jefe.ipfs.nftstorage.link/",
};

export const UVWraps = {
  Air: undefined,
  Grass: "./assets/uv-wraps/grass.png",
  Dirt: "./assets/uv-wraps/dirt.png",
};
