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
import { useEffect, useRef } from "react";
import { VoxelVariantNoaDef, VoxelVariantTypeId } from "@/layers/noa/types";
import { Tileset, getPhaserConfig } from "@/layers/noa/setup/setupPhaser";
import { onStreamUpdate, useStream } from "@/utils/stream";
import { useComponentUpdate } from "@/utils/useComponentUpdate";

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
          getVoxelIconUrl,
          voxelTypes: { VoxelVariantIdToDef, VoxelVariantSubscriptions },
        },
        noa: {
          components: { PlayerPosition },
          streams: { playerPosition$ },
        },
      } = layers;

      onStreamUpdate(playerPosition$, (update) => {
        console.log(update);
      });

      const voxelVariantToIconUrl = (voxelVariantTypeId: VoxelVariantTypeId) => {
        const voxelIconUrl = getVoxelIconUrl(voxelVariantTypeId);
        if (!voxelIconUrl) {
          console.warn("no url found for voxelVariantTypeId=", voxelVariantTypeId);
          return undefined;
        }
        return voxelIconUrl;
      };

      // Draw map for ECS tiles
      //   defineEnterSystem(world, [Has(Position), Has(Item)], ({ entity }) => {
      //     const position = getComponentValueStrict(Position, entity);
      //     const item = getComponentValueStrict(Item, entity).value;

      //     Main.putTileAt(position, 1);
      //   });

      return (
        <div style={{ pointerEvents: "all" }} id="phaser-game">
          hi
        </div>
      );
    },
  });
};
