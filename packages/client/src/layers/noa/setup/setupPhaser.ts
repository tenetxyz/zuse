import {
  defineSceneConfig,
  AssetType,
  defineMapConfig,
  defineScaleConfig,
  defineCameraConfig,
} from "@latticexyz/phaserx";

export enum Assets {
  OverworldTileset = "OverworldTileset",
  MountainTileset = "MountainTileset",
  MainAtlas = "MainAtlas",
  Tileset = "Tileset",
}

export enum Sprites {
  Hero,
  Settlement,
  Gold,
  Inventory,
  GoldShrine,
  EmberCrown,
  EscapePortal,
  Donkey,
}

import overworldTileset from "./overworld-tileset.png";

const TILE_SIZE = 16;
const ANIMATION_INTERVAL = 200;

export const phaserConfig = {
  sceneConfig: {
    Main: defineSceneConfig({
      assets: {
        // TODO: we need to create a tileset from the OPCraft textures and load it here
        [Assets.OverworldTileset]: { type: AssetType.Image, key: Assets.OverworldTileset, path: overworldTileset },
        // [Assets.MainAtlas]: {
        //   type: AssetType.MultiAtlas,
        //   key: Assets.MainAtlas,
        //   path: "/atlases/sprites/atlas.json",
        //   options: {
        //     imagePath: "/atlases/sprites/",
        //   },
        // },
      },
      maps: {
        Main: defineMapConfig({
          chunkSize: TILE_SIZE * 64, // tile size * tile amount
          tileWidth: TILE_SIZE,
          tileHeight: TILE_SIZE,
          backgroundTile: [1],
          animationInterval: ANIMATION_INTERVAL,
          tileAnimations: {},
          layers: {
            layers: {
              Background: { tilesets: ["Default"], hasHueTintShader: true },
              Foreground: { tilesets: ["Default"], hasHueTintShader: true },
            },
            defaultLayer: "Background",
          },
        }),
      },
      sprites: {
        [Sprites.Settlement]: {
          assetKey: Assets.MainAtlas,
          frame: "sprites/resources/crystal.png",
        },
      },
      animations: [],
      tilesets: {
        Default: { assetKey: Assets.OverworldTileset, tileWidth: TILE_SIZE, tileHeight: TILE_SIZE },
      },
    }),
  },
  scale: defineScaleConfig({
    parent: "phaser-game",
    zoom: 2,
    mode: Phaser.Scale.NONE,
    // width: "500px", // this doens't work :(
    // height: "500px",
  }),
  cameraConfig: defineCameraConfig({
    // phaserSelector: "phaser-game",
    pinchSpeed: 1,
    wheelSpeed: 1,
    maxZoom: 4,
    minZoom: 1,
  }),
  cullingChunkSize: TILE_SIZE * 16,
};
