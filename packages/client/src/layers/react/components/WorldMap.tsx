import {
  defineSceneConfig,
  AssetType,
  defineScaleConfig,
  defineMapConfig,
  defineCameraConfig,
  createPhaserEngine,
  createChunks,
  createAnimatedTilemap,
} from "@latticexyz/phaserx";
import { defineEnterSystem } from "@latticexyz/recs";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { Layers } from "@/types";
import { useEffect } from "react";
import { phaserConfig } from "@/layers/noa/setup/setupPhaser";
import { VoxelVariantNoaDef, VoxelVariantTypeId } from "@/layers/noa/types";

const TILE_SIZE = 16;
const ANIMATION_INTERVAL = 200;
export const registerWorldMap = () => {
  registerTenetComponent({
    rowStart: 2,
    rowEnd: 6,
    columnStart: 1,
    columnEnd: 4,
    Component: ({ layers }) => {
      const {
        network: {
          world,
          actions: { Action },
          config: { blockExplorer },
          getVoxelIconUrl,
          objectStore: { transactionCallbacks },
          voxelTypes: { VoxelVariantIdToDef, VoxelVariantSubscriptions },
        },
      } = layers;
      const {
        noa: {
          // phaser: {
          //   scenes: {
          //     Main: {
          //       camera: { phaserCamera, worldView$ },
          //       maps: {
          //         Main: { putTileAt },
          //       },
          //     },
          //   },
          //   game,
          // },
        },
      } = layers;
      useEffect(() => {
        (async () => {
          const phaser = await createPhaserEngine(phaserConfig);
          const { game, scenes, dispose: disposePhaser } = phaser; // I unwrapped these vars here just for documentation purposes
          // console.log(inspect(game));
          // console.log(inspect(scenes));
          // createAnimatedTilemap;
          // game.scene.
          debugger;
          world.registerDisposer(disposePhaser);
          const {
            camera: { phaserCamera, worldView$ },
            maps: {
              Main: { putTileAt },
            },
          } = scenes.Main;
          // Phaser.Tilemaps.Tilemap.

          for (const phaserScene of game.scene.getScenes(false)) {
            const emptyMap = new Phaser.Tilemaps.Tilemap(phaserScene, new Phaser.Tilemaps.MapData());
            // const tileset emptyMap.addTilesetImage();
            // if (!tileset) {
            //   console.error(`Adding tileset ${tilesetKey} failed.`);
            //   continue;
            // }
          }

          for (const [voxelVariantTypeId, voxelVariantNoaDef] of VoxelVariantIdToDef.entries()) {
            // VoxelVariantSubscriptions.push();
            // addTilesetImage(voxelVariantNoaDef.name, voxelVariantNoaDef.name);
          }

          phaserCamera.setBounds(-1000, -1000, 2000, 2000);
          phaserCamera.centerOn(0, 0);
          putTileAt({ x: 0, y: 0 }, 2); // puts on default background layer
          putTileAt({ x: 1, y: 0 }, 10); // puts on default background layer
          const phaserCanvas = document.querySelectorAll("#phaser-game canvas")[0];
          // not sure if there's a param within phaser to set the size of the canvas
          phaserCanvas.style.height = 200 + "px";
          phaserCanvas.style.width = 200 * getScreenRatio() + "px";

          const chunks = createChunks(worldView$, 16 * 16); // Tile size in pixels * Tiles per chunk
        })();
        // world.registerDisposer(disposePhaser);
      }, []);

      // Draw map for ECS tiles
      //   defineEnterSystem(world, [Has(Position), Has(Item)], ({ entity }) => {
      //     const position = getComponentValueStrict(Position, entity);
      //     const item = getComponentValueStrict(Item, entity).value;

      //     Main.putTileAt(position, 1);
      //   });

      return <div style={{ pointerEvents: "all" }} id="phaser-game"></div>;
    },
  });
};

function getScreenRatio() {
  var screenWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
  var screenHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
  var ratio = screenWidth / screenHeight;
  return ratio;
}
