import {
  defineSceneConfig,
  AssetType,
  defineScaleConfig,
  defineMapConfig,
  defineCameraConfig,
  createPhaserEngine,
  createChunks,
} from "@latticexyz/phaserx";
import { defineEnterSystem } from "@latticexyz/recs";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { Layers } from "@/types";
import { useEffect } from "react";
import { phaserConfig } from "@/layers/noa/setup/setupPhaser";

const TILE_SIZE = 16;
const ANIMATION_INTERVAL = 200;
export const registerWorldMap = () => {
  registerTenetComponent({
    rowStart: 1,
    rowEnd: 4,
    columnStart: 2,
    columnEnd: 10,
    Component: ({ layers }) => {
      const {
        network: {
          world,
          actions: { Action },
          config: { blockExplorer },
          getVoxelIconUrl,
          objectStore: { transactionCallbacks },
        },
      } = layers;
      const {
        noa: {
          // phaser: {
          //   scenes: {
          //     Main: {
          //       maps: { Main },
          //     },
          //   },
          // },
        },
      } = layers;
      useEffect(() => {
        (async () => {
          const phaser = await createPhaserEngine(phaserConfig);
          const { game, scenes, dispose: disposePhaser } = phaser; // I unwrapped these vars here just for documentation purposes

          const {
            Main: {
              camera: { phaserCamera },
              maps: {
                Main: { putTileAt },
              },
            },
          } = scenes;
          phaserCamera.setBounds(-1000, -1000, 2000, 2000);
          phaserCamera.centerOn(0, 0);
          putTileAt({ x: 0, y: 0 }, 1); // puts on default background layer

          const chunks = createChunks(scenes.Main.camera.worldView$, 16 * 16); // Tile size in pixels * Tiles per chunk
          world.registerDisposer(disposePhaser);
        })();
      }, []);

      // Draw map for ECS tiles
      //   defineEnterSystem(world, [Has(Position), Has(Item)], ({ entity }) => {
      //     const position = getComponentValueStrict(Position, entity);
      //     const item = getComponentValueStrict(Item, entity).value;

      //     Main.putTileAt(position, 1);
      //   });

      return (
        <div className="w-100 h-100">
          <div style={{ height: 50, width: 50 }} id="phaser-game"></div>
        </div>
      );
    },
  });
};
