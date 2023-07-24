import { VoxelCoord } from "@latticexyz/utils";
import { NoaVoxelDef, NoaBlockType } from "./types";

export const CRAFTING_SIDE = 3;
// export const SPAWN_POINT: VoxelCoord = { x: -1543, y: 11, z: -808 };
export const SPAWN_POINT: VoxelCoord = { x: 0, y: 11, z: 0 };
export const CRAFTING_SIZE = CRAFTING_SIDE * CRAFTING_SIDE;
export const EMPTY_CRAFTING_TABLE = [...new Array(CRAFTING_SIZE)].map(() => -1);
export const MINING_DURATION = 300;
export const FAST_MINING_DURATION = 200;
export const GRAVITY_MULTIPLIER = 2;

const nftStorageLinkFormat = "https://${hash}.ipfs.nftstorage.link/";

export function getNftStorageLink(hash: string) {
  return nftStorageLinkFormat.replace("${hash}", hash);
}

export const Textures = {
  Grass: getNftStorageLink("bafkreifmvm3yxzbkzcb2r7m6gavjhe22n4p3o36lz2ypkgf5v6i6zzhv4a"),
  GrassSide: getNftStorageLink("bafkreibp5wefex2cunqz5ffwt3ucw776qthwl6y6pswr2j2zuzldrv6bqa"),
  Dirt: getNftStorageLink("bafkreibzraiuk6hgngtfczn57sivuqf3nv77twi6g3ftas2umjnbf6jefe"),
  Bedrock: getNftStorageLink("bafkreidfo756faklwx7o4q2753rxjqx6egzpmqh2zhylxaehqalvws555a"),
  Tile: getNftStorageLink("bafkreiflbvybgotxeaaapdknflsgenpskbl6zp2ttzvt5qlwcwwo7t75qm"),
  Tile2: getNftStorageLink("bafkreifun5pqgayquwuhorneu67bbz5q6mizqq323rxcszftlloatzavuq"),
};

export const UVWraps = {
  Air: undefined,
  Grass: getNftStorageLink("bafkreihaagdyqnbie3eyx6upmoul2zb4qakubxg6bcha6k5ebp4fbsd3am"),
  Dirt: getNftStorageLink("bafkreifbshwckn4pgw5ew2obz3i74eujzpcomatus5gu2tk7mms373gqme"),
  Bedrock: getNftStorageLink("bafkreihdit6glam7sreijo7itbs7uwc2ltfeuvcfaublxf6rjo24hf6t4y"),
  Tile: getNftStorageLink("bafkreidmmv32qdtob3p4yt475xuvbwoovjd2iifrnxh4icyl44xyl6gtfe"),
  Tile2: getNftStorageLink("bafkreidp4ec6ntaqoxhc6fdjearell4hqynvgkrmpepmtvdrkikmt72kfe"),
};
