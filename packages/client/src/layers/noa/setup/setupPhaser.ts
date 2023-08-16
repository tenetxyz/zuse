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
  TileHover = "TileHover",
  Dirt = "Dirt", // This is just a filler tileset so we can have a default tileset to show
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

export interface Tileset {
  noaBlockIdx: string;
  path: string;
}

export const getPhaserConfig = (tilesets: Tileset[]) => {
  const tilesetAssets: any = {
    [Assets.Dirt]: {
      type: AssetType.Image,
      key: Assets.Dirt,
      path: "https://bafkreihy3pblhqaqquwttcykwlyey3umpou57rkvtncpdrjo7mlgna53g4.ipfs.nftstorage.link/",
    },
  };
  const tilesetKeys = Array.from(Object.keys(tilesetAssets));

  return {
    sceneConfig: {
      Main: defineSceneConfig({
        // assets: {
        //   [Assets.OverworldTileset]: { type: AssetType.Image, key: Assets.OverworldTileset, path: overworldTileset },
        // [Assets.MainAtlas]: {
        //   type: AssetType.MultiAtlas,
        //   key: Assets.MainAtlas,
        //   path: "/atlases/sprites/atlas.json",
        //   options: {
        //     imagePath: "/atlases/sprites/",
        //   },
        // },
        // },
        assets: tilesetAssets,
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
                // Background: { tilesets: ["Default"], hasHueTintShader: true },
                // Foreground: { tilesets: ["Default"], hasHueTintShader: true },
                // as any was needed so typescript doesn't complain
                Background: { tilesets: tilesetKeys as any, hasHueTintShader: true },
                Foreground: { tilesets: tilesetKeys as any, hasHueTintShader: true },
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
          Default: { assetKey: Assets.Dirt, tileWidth: TILE_SIZE, tileHeight: TILE_SIZE },
        },
        preload: (scene: Phaser.Scene) => {
          console.log("preload");
          for (const tileset of tilesets) {
            scene.load.image(tileset.noaBlockIdx, tileset.path);
          }
          console.log(tilesets);
        },
      }),
    },
    scale: defineScaleConfig({
      parent: "phaser-game",
      // zoom: 2,
      mode: Phaser.Scale.RESIZE, // if you use Phaser.Scale.NONE, the canvas will try to take up the entire screen
      // mode: Phaser.Scale.NONE,
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
};
