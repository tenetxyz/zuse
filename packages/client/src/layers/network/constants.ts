import { Entity } from "@latticexyz/recs";
import { keccak256 } from "@latticexyz/utils";

const VoxelTypeKeyToId = {
  Air: keccak256("voxel.Air") as Entity,
  Grass: keccak256("voxel.Grass") as Entity,
  Dirt: keccak256("voxel.Dirt") as Entity,
  Log: keccak256("voxel.Log") as Entity,
  Stone: keccak256("voxel.Stone") as Entity,
  Sand: keccak256("voxel.Sand") as Entity,
  Glass: keccak256("voxel.Glass") as Entity,
  Water: keccak256("voxel.Water") as Entity,
  Cobblestone: keccak256("voxel.Cobblestone") as Entity,
  MossyCobblestone: keccak256("voxel.MossyCobblestone") as Entity,
  Coal: keccak256("voxel.Coal") as Entity,
  Crafting: keccak256("voxel.Crafting") as Entity,
  Iron: keccak256("voxel.Iron") as Entity,
  Gold: keccak256("voxel.Gold") as Entity,
  Diamond: keccak256("voxel.Diamond") as Entity,
  Leaves: keccak256("voxel.Leaves") as Entity,
  Planks: keccak256("voxel.Planks") as Entity,
  RedFlower: keccak256("voxel.RedFlower") as Entity,
  GrassPlant: keccak256("voxel.GrassPlant") as Entity,
  OrangeFlower: keccak256("voxel.OrangeFlower") as Entity,
  MagentaFlower: keccak256("voxel.MagentaFlower") as Entity,
  LightBlueFlower: keccak256("voxel.LightBlueFlower") as Entity,
  LimeFlower: keccak256("voxel.LimeFlower") as Entity,
  PinkFlower: keccak256("voxel.PinkFlower") as Entity,
  GrayFlower: keccak256("voxel.GrayFlower") as Entity,
  LightGrayFlower: keccak256("voxel.LightGrayFlower") as Entity,
  CyanFlower: keccak256("voxel.CyanFlower") as Entity,
  PurpleFlower: keccak256("voxel.PurpleFlower") as Entity,
  BlueFlower: keccak256("voxel.BlueFlower") as Entity,
  GreenFlower: keccak256("voxel.GreenFlower") as Entity,
  BlackFlower: keccak256("voxel.BlackFlower") as Entity,
  Kelp: keccak256("voxel.Kelp") as Entity,
  Wool: keccak256("voxel.Wool") as Entity,
  OrangeWool: keccak256("voxel.OrangeWool") as Entity,
  MagentaWool: keccak256("voxel.MagentaWool") as Entity,
  LightBlueWool: keccak256("voxel.LightBlueWool") as Entity,
  YellowWool: keccak256("voxel.YellowWool") as Entity,
  LimeWool: keccak256("voxel.LimeWool") as Entity,
  PinkWool: keccak256("voxel.PinkWool") as Entity,
  GrayWool: keccak256("voxel.GrayWool") as Entity,
  LightGrayWool: keccak256("voxel.LightGrayWool") as Entity,
  CyanWool: keccak256("voxel.CyanWool") as Entity,
  PurpleWool: keccak256("voxel.PurpleWool") as Entity,
  BlueWool: keccak256("voxel.BlueWool") as Entity,
  BrownWool: keccak256("voxel.BrownWool") as Entity,
  GreenWool: keccak256("voxel.GreenWool") as Entity,
  RedWool: keccak256("voxel.RedWool") as Entity,
  BlackWool: keccak256("voxel.BlackWool") as Entity,
  Sponge: keccak256("voxel.Sponge") as Entity,
  Snow: keccak256("voxel.Snow") as Entity,
  Clay: keccak256("voxel.Clay") as Entity,
  Bedrock: keccak256("voxel.Bedrock") as Entity,
  Bricks: keccak256("voxel.Bricks") as Entity,
};

export type VoxelTypeKey = keyof typeof VoxelTypeKeyToId;

const VoxelTypeIdToIndex = Object.values(VoxelTypeKeyToId).reduce<{
  [key: string]: number;
}>((acc, id, index) => {
  acc[id] = index;
  return acc;
}, {});

const VoxelTypeIndexToId = Object.values(VoxelTypeKeyToId).reduce<{
  [key: number]: string;
}>((acc, id, index) => {
  acc[index] = id;
  return acc;
}, {});

const VoxelTypeIndexToKey = Object.entries(VoxelTypeKeyToId).reduce<{
  [key: number]: VoxelTypeKey;
}>((acc, [key], index) => {
  acc[index] = key as VoxelTypeKey;
  return acc;
}, {});

const VoxelTypeIdToKey = Object.entries(VoxelTypeKeyToId).reduce<{
  [key: Entity]: VoxelTypeKey;
}>((acc, [key, id]) => {
  acc[id] = key as VoxelTypeKey;
  return acc;
}, {});
