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
import { Has, defineEnterSystem, defineRxSystem, getComponentValueStrict } from "@latticexyz/recs";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { Layers } from "@/types";
import { useEffect, useRef } from "react";
import { VoxelVariantNoaDef, VoxelVariantTypeId } from "@/layers/noa/types";
import { Tileset, getPhaserConfig } from "@/layers/noa/setup/setupPhaser";
import { onStreamUpdate, useStream } from "@/utils/stream";
import { getWorldScale } from "@/utils/coord";
import { getVoxelAtPosition } from "@/layers/network/api";
import { CHUNK_SIZE } from "@/layers/noa/setup/constants";
import { TILE_Y } from "@/layers/network/api/terrain/occurrence";

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
          streams: { playerPosition$ },
        },
        network: {
          api: { getVoxelAtPosition, getTerrainVoxelTypeAtPosition },
          world,
          actions: { Action },
          getVoxelIconUrl,
          objectStore: { transactionCallbacks },
          voxelTypes: { VoxelVariantIdToDef, VoxelVariantSubscriptions },
          streams: { doneSyncing$ },
          components: { Position, VoxelType },
        },
      } = layers;
      const minimapCamera = useRef<Phaser.Cameras.Scene2D.Camera>();
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
          noaBlockIdx: voxelVariantNoaDef.noaBlockIdx.toString(),
          path: voxelIconUrl,
        };
      };
      useEffect(() => {
        // populate the tilesets array with noaBlockId and the path to the sprite
        for (const [voxelVariantTypeId, voxelVariantNoaDef] of VoxelVariantIdToDef.entries()) {
          const tileset = voxelVariantToTileSet(voxelVariantTypeId, voxelVariantNoaDef);
          if (tileset) {
            tilesets.current.push(tileset);
          }
        }

        VoxelVariantSubscriptions.push(
          (voxelVariantTypeId: VoxelVariantTypeId, voxelVariantNoaDef: VoxelVariantNoaDef) => {
            const tileset = voxelVariantToTileSet(voxelVariantTypeId, voxelVariantNoaDef);
            if (tileset) {
              tilesets.current.push(tileset);
            }
          }
        );
      }, []);

      const isDoneSyncingWorlds = useStream(doneSyncing$);
      useEffect(() => {
        if (isDoneSyncingWorlds) {
          renderPhaser();
        }
      }, [isDoneSyncingWorlds]);

      const renderPhaser = async () => {
        const phaser = await createPhaserEngine(getPhaserConfig(tilesets.current));
        const { game, scenes, dispose: disposePhaserFunc } = phaser; // I unwrapped these vars here just for documentation purposes
        console.log("Loaded phaser");
        world.registerDisposer(disposePhaserFunc);
        const {
          phaserScene,
          camera: { phaserCamera, worldView$ },
        } = scenes.Main;

        phaserCamera.setBounds(-1000, -1000, 2000, 2000);
        phaserCamera.centerOn(0, 0);
        minimapCamera.current = phaserCamera;

        const renderSpriteAtCoord = (noaBlockIdx: number, x: number, z: number) => {
          const sprite = phaserScene.add.sprite(x * TILE_SIZE, z * TILE_SIZE, noaBlockIdx.toString()).setOrigin(0, 0);
          sprite.displayHeight = TILE_SIZE;
          sprite.displayWidth = TILE_SIZE;
        };
        // Draw map for ECS tiles
        // "Enter system"
        defineEnterSystem(world, [Has(Position), Has(VoxelType)], (update) => {
          if (!isDoneSyncingWorlds) return;
          const entityKey = update.entity;
          const worldScale = getWorldScale(noa);
          const position = getComponentValueStrict(Position, entityKey);
          const voxel = getVoxelAtPosition(position, worldScale); // TODO: do we even need this funciton? we already have the entity from teh update, so it probably isn't a terrain block. I think we can just use getVoxelType for the given entity (after getting its position)
          const voxelVariantNoaDef = VoxelVariantIdToDef.get(voxel.voxelVariantTypeId as string);
          if (
            !voxelVariantNoaDef ||
            (voxelVariantNoaDef.noaBlockIdx === 0 && voxelVariantNoaDef.noaVoxelDef === undefined)
          ) {
            console.warn(`cannot find noaBlockIdx for voxelVariantId=${voxel.voxelVariantTypeId}`);
            return;
          }
          const noaBlockIdx = voxelVariantNoaDef.noaBlockIdx;
          renderSpriteAtCoord(noaBlockIdx, position.x, position.z);
        });

        // Why are we making a new chunks object, why not reuse the one in createNoaLayer (where the player's chunkd render area is defined)
        // cause the user may scroll away on the map, meaning we'd have to render new chunks the player isn't in rn
        const chunks = createChunks(worldView$, CHUNK_SIZE);
        defineRxSystem(world, chunks.addedChunks$, (chunk) => {
          const tilesPerChunk = CHUNK_SIZE;
          // since the worldgen is simple, we just get the tile for that y-level;
          const coord = { x: 0, y: TILE_Y, z: 0 };
          debugger;
          const terrainTile = getTerrainVoxelTypeAtPosition(coord, getWorldScale(noa));
          const noaBlockIdx = variantIdToNoaBlockIdx.get(terrainTile.voxelVariantTypeId);
          if (!noaBlockIdx) {
            console.warn(`cannot find noaBlockIdx for voxelVariantId=${terrainTile.voxelVariantTypeId}`);
            return;
          }
          for (let xOffset = 0; xOffset < tilesPerChunk; xOffset += 1) {
            for (let zOffset = 0; zOffset < tilesPerChunk; zOffset += 1) {
              const x = chunk.x * tilesPerChunk + xOffset;
              const z = chunk.y * tilesPerChunk + zOffset; // yes. chunk.y

              // TODO: investigate why variantIdToNoaBlockIdx and VoxelVariantIdToDef doesn't contain all the blockIdxes for terrainTile.voxelVariantTypeId or voxel.voxelVariantTypeId (in the function above)
              renderSpriteAtCoord(noaBlockIdx, x, z);
            }
          }
        });
      };

      onStreamUpdate(playerPosition$, (update) => {
        if (minimapCamera.current === undefined) {
          return;
        }
        minimapCamera.current.centerOn(Math.round(update.x) * TILE_SIZE, Math.round(update.z) * TILE_SIZE);
        // Even without Math.round, the image looks choppy (it doesn't update fast enough)
        // minimapCamera.current.centerOn(update.x * TILE_SIZE, update.z * TILE_SIZE);
      });

      // As a last resort, you can use this to change the size of the canvas
      // const phaserCanvas = document.querySelectorAll("#phaser-game canvas")[0];
      // phaserCanvas.style.height = 200 + "px";
      // phaserCanvas.style.width = 200 * getScreenRatio() + "px";
      return <div style={{ pointerEvents: "all" }} id="phaser-game"></div>;
    },
  });
};
