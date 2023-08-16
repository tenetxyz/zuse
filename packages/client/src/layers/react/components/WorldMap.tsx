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
import { Has, defineEnterSystem, getComponentValueStrict } from "@latticexyz/recs";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { Layers } from "@/types";
import { useEffect, useRef } from "react";
import { VoxelVariantNoaDef, VoxelVariantTypeId } from "@/layers/noa/types";
import { Tileset, getPhaserConfig } from "@/layers/noa/setup/setupPhaser";
import { useStream } from "@/utils/stream";
import { getWorldScale } from "@/utils/coord";
import { getVoxelAtPosition } from "@/layers/network/api";

const TILE_SIZE = 16;
const ANIMATION_INTERVAL = 200;
export const registerWorldMap = () => {
  registerTenetComponent({
    rowStart: 3,
    rowEnd: 6,
    columnStart: 8,
    columnEnd: 12,
    Component: ({ layers }) => {
      const {
        noa: {
          noa,
          objectStore: { variantIdToNoaBlockIdx },
        },
        network: {
          api: { getVoxelAtPosition },
          world,
          actions: { Action },
          config: { blockExplorer },
          getVoxelIconUrl,
          objectStore: { transactionCallbacks },
          voxelTypes: { VoxelVariantIdToDef, VoxelVariantSubscriptions },
          streams: { doneSyncing$ },
          components: { Position, VoxelType },
        },
      } = layers;
      const disposePhaser = useRef<any>();
      const tilesets = useRef<Tileset[]>([]);

      const voxelVariantToTileSet = (
        voxelVariantTypeId: VoxelVariantTypeId,
        voxelVariantNoaDef: VoxelVariantNoaDef
      ) => {
        const voxelIconUrl = getVoxelIconUrl(voxelVariantTypeId);
        if (!voxelIconUrl) {
          console.warn("no url found for voxelVariantTypeId=", voxelVariantTypeId);
          return undefined;
        }
        return {
          name: voxelVariantNoaDef.noaBlockIdx.toString(),
          path: voxelIconUrl,
        };
      };
      useEffect(() => {
        // initial load
        for (const [voxelVariantTypeId, voxelVariantNoaDef] of VoxelVariantIdToDef.entries()) {
          const tileset = voxelVariantToTileSet(voxelVariantTypeId, voxelVariantNoaDef);
          if (tileset) {
            tilesets.current.push(tileset);
          }
        }

        console.log("render 1");
        VoxelVariantSubscriptions.push(
          (voxelVariantTypeId: VoxelVariantTypeId, voxelVariantNoaDef: VoxelVariantNoaDef) => {
            const tileset = voxelVariantToTileSet(voxelVariantTypeId, voxelVariantNoaDef);
            if (tileset) {
              tilesets.current.push(tileset);
              console.log("render 2");
            }
          }
        );
      }, []);

      const isDoneSyncingWorlds = useStream(doneSyncing$);
      useEffect(() => {
        if (isDoneSyncingWorlds) {
          console.log("finished syncing");
          renderPhaser(tilesets.current);
        }
      }, [isDoneSyncingWorlds]);

      const renderPhaser = async (tilesets: Tileset[]) => {
        const phaser = await createPhaserEngine(getPhaserConfig(tilesets));
        const { game, scenes, dispose: disposePhaserFunc } = phaser; // I unwrapped these vars here just for documentation purposes
        world.registerDisposer(disposePhaserFunc);
        // console.log(inspect(game));
        // console.log(inspect(scenes));
        // createAnimatedTilemap;
        // game.scene.
        const {
          phaserScene,
          camera: { phaserCamera, worldView$ },
          maps: {
            Main: { putTileAt },
          },
        } = scenes.Main;

        phaserCamera.setBounds(-1000, -1000, 2000, 2000);
        phaserCamera.centerOn(0, 0);

        // phaserScene.add.sprite(0, 0, "6").setOrigin(0, 0);
        // putTileAt({ x: 0, y: 0 }, 3, "Background"); // puts on default background layer
        // putTileAt({ x: 1, y: 0 }, 10); // puts on default background layer
        // putTileAt({ x: 1, y: 0 }, 4, "Background"); // puts on default background layer
        console.log("FINISHED PUTTING TILES");
        const phaserCanvas = document.querySelectorAll("#phaser-game canvas")[0];

        // const chunks = createChunks(worldView$, 16 * 16); // Tile size in pixels * Tiles per chunk

        // Draw map for ECS tiles
        // "Enter system"
        defineEnterSystem(world, [Has(Position), Has(VoxelType)], (update) => {
          if (!isDoneSyncingWorlds) return;
          const entityKey = update.entity;
          const worldScale = getWorldScale(noa);
          const position = getComponentValueStrict(Position, entityKey);
          const voxel = getVoxelAtPosition(position, worldScale); // TODO: do we even need this funciton? we already have the entity from teh update, so it probably isn't a terrain block. I think we can just use getVoxelType for the given entity (after getting its position)
          // const noaBlockIdx = variantIdToNoaBlockIdx.get();
          const voxelVariantNoaDef = VoxelVariantIdToDef.get(voxel.voxelVariantTypeId as string);
          if (
            !voxelVariantNoaDef ||
            (voxelVariantNoaDef.noaBlockIdx === 0 && voxelVariantNoaDef.noaVoxelDef === undefined)
          ) {
            console.warn(`cannot find noaBlockIdx for voxelVariantId=${voxel.voxelVariantTypeId}`);
            return;
          }
          const noaBlockIdx = voxelVariantNoaDef.noaBlockIdx;
          const sprite = phaserScene.add
            .sprite(position.x * TILE_SIZE, position.z * TILE_SIZE, noaBlockIdx.toString())
            .setOrigin(0, 0);
          sprite.displayHeight = TILE_SIZE;
          sprite.displayWidth = TILE_SIZE;
        });
      };

      // As a last resort, you can use this to change the size of the canvas
      // phaserCanvas.style.height = 200 + "px";
      // phaserCanvas.style.width = 200 * getScreenRatio() + "px";
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
