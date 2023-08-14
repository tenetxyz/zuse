import {
  defineSceneConfig,
  AssetType,
  defineScaleConfig,
  defineMapConfig,
  defineCameraConfig,
  createPhaserEngine,
} from "@latticexyz/phaserx";
import { defineEnterSystem } from "@latticexyz/recs";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { Layers } from "@/types";

const TILE_SIZE = 16;
const ANIMATION_INTERVAL = 200;
export const registerWorldMap = () => {
  registerTenetComponent({
    rowStart: 0,
    rowEnd: 0,
    columnStart: 0,
    columnEnd: 0,
    Component: ({ layers }) => {
      const {
        network: {
          actions: { Action },
          config: { blockExplorer },
          getVoxelIconUrl,
          objectStore: { transactionCallbacks },
        },
      } = layers;
      const {
        noa: {
          phaser: {
            scenes: {
              Main: {
                maps: { Main },
              },
            },
          },
        },
      } = layers;

      // Draw map for ECS tiles
      //   defineEnterSystem(world, [Has(Position), Has(Item)], ({ entity }) => {
      //     const position = getComponentValueStrict(Position, entity);
      //     const item = getComponentValueStrict(Item, entity).value;

      //     Main.putTileAt(position, 1);
      //   });

      return (
        <div>
          <div id="phaser-game"></div>
          <div id="react-root"></div>
        </div>
      );
    },
  });
};
