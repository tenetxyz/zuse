import { Entity } from "@latticexyz/recs";
import { keccak256 } from "@latticexyz/utils";

export const BlockType = {
  Air: keccak256("block.Air") as Entity,
  Grass: keccak256("block.Grass") as Entity,
  Dirt: keccak256("block.Dirt") as Entity,
  Log: keccak256("block.Log") as Entity,
  Stone: keccak256("block.Stone") as Entity,
  Sand: keccak256("block.Sand") as Entity,
  Glass: keccak256("block.Glass") as Entity,
  Water: keccak256("block.Water") as Entity,
  Cobblestone: keccak256("block.Cobblestone") as Entity,
  MossyCobblestone: keccak256("block.MossyCobblestone") as Entity,
  Coal: keccak256("block.Coal") as Entity,
  Crafting: keccak256("block.Crafting") as Entity,
  Iron: keccak256("block.Iron") as Entity,
  Gold: keccak256("block.Gold") as Entity,
  Diamond: keccak256("block.Diamond") as Entity,
  Leaves: keccak256("block.Leaves") as Entity,
  Planks: keccak256("block.Planks") as Entity,
  RedFlower: keccak256("block.RedFlower") as Entity,
  GrassPlant: keccak256("block.GrassPlant") as Entity,
  OrangeFlower: keccak256("block.OrangeFlower") as Entity,
  MagentaFlower: keccak256("block.MagentaFlower") as Entity,
  LightBlueFlower: keccak256("block.LightBlueFlower") as Entity,
  LimeFlower: keccak256("block.LimeFlower") as Entity,
  PinkFlower: keccak256("block.PinkFlower") as Entity,
  GrayFlower: keccak256("block.GrayFlower") as Entity,
  LightGrayFlower: keccak256("block.LightGrayFlower") as Entity,
  CyanFlower: keccak256("block.CyanFlower") as Entity,
  PurpleFlower: keccak256("block.PurpleFlower") as Entity,
  BlueFlower: keccak256("block.BlueFlower") as Entity,
  GreenFlower: keccak256("block.GreenFlower") as Entity,
  BlackFlower: keccak256("block.BlackFlower") as Entity,
  Kelp: keccak256("block.Kelp") as Entity,
  Wool: keccak256("block.Wool") as Entity,
  OrangeWool: keccak256("block.OrangeWool") as Entity,
  MagentaWool: keccak256("block.MagentaWool") as Entity,
  LightBlueWool: keccak256("block.LightBlueWool") as Entity,
  YellowWool: keccak256("block.YellowWool") as Entity,
  LimeWool: keccak256("block.LimeWool") as Entity,
  PinkWool: keccak256("block.PinkWool") as Entity,
  GrayWool: keccak256("block.GrayWool") as Entity,
  LightGrayWool: keccak256("block.LightGrayWool") as Entity,
  CyanWool: keccak256("block.CyanWool") as Entity,
  PurpleWool: keccak256("block.PurpleWool") as Entity,
  BlueWool: keccak256("block.BlueWool") as Entity,
  BrownWool: keccak256("block.BrownWool") as Entity,
  GreenWool: keccak256("block.GreenWool") as Entity,
  RedWool: keccak256("block.RedWool") as Entity,
  BlackWool: keccak256("block.BlackWool") as Entity,
  Sponge: keccak256("block.Sponge") as Entity,
  Snow: keccak256("block.Snow") as Entity,
  Clay: keccak256("block.Clay") as Entity,
  Bedrock: keccak256("block.Bedrock") as Entity,
  Bricks: keccak256("block.Bricks") as Entity,
};

export type BlockTypeKey = keyof typeof BlockType;

export const BlockIdToIndex = Object.values(BlockType).reduce<{ [key: string]: number }>((acc, id, index) => {
  acc[id] = index;
  return acc;
}, {});

export const BlockIndexToId = Object.values(BlockType).reduce<{ [key: number]: string }>((acc, id, index) => {
  acc[index] = id;
  return acc;
}, {});

export const BlockIndexToKey = Object.entries(BlockType).reduce<{ [key: number]: BlockTypeKey }>(
  (acc, [key], index) => {
    acc[index] = key as BlockTypeKey;
    return acc;
  },
  {}
);

export const BlockIdToKey = Object.entries(BlockType).reduce<{ [key: Entity]: BlockTypeKey }>((acc, [key, id]) => {
  acc[id] = key as BlockTypeKey;
  return acc;
}, {});
