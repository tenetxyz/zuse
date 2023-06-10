/* eslint-disable @typescript-eslint/ban-ts-comment */
import { Engine } from "noa-engine";
// add a mesh to represent the player, and scale it, etc.
import "@babylonjs/core/Meshes/Builders/boxBuilder";
import * as BABYLON from "@babylonjs/core";
import { VoxelCoord } from "@latticexyz/utils";
import { Blocks, Textures } from "../constants";
import { VoxelTypeKeyToId, VoxelTypeIdToIndex } from "../../network";
import { Entity } from "@latticexyz/recs";
import { NoaBlockType } from "../types";
import { createMeshBlock } from "./utils";
import { VoxelTypeIndexToKey, VoxelTypeKey } from "../../network/constants";
import { setupScene } from "../engine/setupScene";
import {
  CHUNK_RENDER_DISTANCE,
  CHUNK_SIZE,
  MIN_HEIGHT,
  SKY_COLOR,
} from "./constants";

export interface API {
  getTerrainBlockAtPosition: (coord: VoxelCoord) => Entity;
  getECSBlockAtPosition: (coord: VoxelCoord) => Entity | undefined;
}

export function setupNoaEngine(api: API) {
  const opts = {
    debug: false,
    // TODO: log this FPS data to a metrics service
    showFPS: true, // how to read FPS: https://github.com/fenomas/noa/blob/bd74cd8add3abf216b53a995139276af665b1d52/src/lib/rendering.js#LL611C13-L611C22
    // The top number is the average FPS, the bottom is the WORSE fps experienced so far
    inverseY: false,
    inverseX: false,
    chunkAddDistance: [CHUNK_RENDER_DISTANCE + 3, CHUNK_RENDER_DISTANCE + 3],
    chunkRemoveDistance: [CHUNK_RENDER_DISTANCE + 8, CHUNK_RENDER_DISTANCE + 8],
    chunkSize: CHUNK_SIZE,
    gravity: [0, -20, 0],
    playerStart: [-20000, 100, 20000],
    blockTestDistance: 7,
    playerHeight: 1.85,
    playerWidth: 0.6,
    playerAutoStep: 1,
    clearColor: SKY_COLOR,
    useAO: true,
    AOmultipliers: [0.93, 0.8, 0.5],
    reverseAOmultiplier: 1.0,
    preserveDrawingBuffer: true,
  };

  // Hack Babylon in order to have a -1 rendering group for the sky (to be always drawn behind everything else)
  BABYLON.RenderingManager.MIN_RENDERINGGROUPS = -1;

  const noa = new Engine(opts);
  const scene = noa.rendering.getScene();
  noa.world.worldGenWhilePaused = false;

  // Make player float before world is loaded
  const body = noa.ents.getPhysics(1)?.body;
  if (body) body.gravityMultiplier = 0;

  customizePlayerMovement(noa);

  // Note: this is the amount of time, per tick, spent requesting chunks from userland and meshing them
  // IT DOES NOT INCLUDE TIME SPENT BY THE CLIENT GENERATING THE CHUNKS
  noa.world.maxProcessingPerTick = 12;
  noa.world.maxProcessingPerRender = 8;
  // Register simple materials
  const textures = Object.values(Blocks).reduce<string[]>(
    (materials, block) => {
      if (!block || !block.material) return materials;
      const blockMaterials = (
        Array.isArray(block.material) ? block.material : [block.material]
      ) as string[];
      if (blockMaterials) materials.push(...blockMaterials);
      return materials;
    },
    []
  );

  for (const texture of textures) {
    noa.registry.registerMaterial(texture, undefined, texture);
  }

  // override the two water materials
  noa.registry.registerMaterial(
    Textures.TransparentWater,
    [146 / 255, 215 / 255, 233 / 255, 0.5],
    undefined,
    true
  );
  noa.registry.registerMaterial(
    Textures.Water,
    [1, 1, 1, 0.7],
    Textures.Water,
    true
  );
  noa.registry.registerMaterial(
    Textures.Leaves,
    undefined,
    Textures.Leaves,
    true
  );
  noa.registry.registerMaterial(
    Textures.Glass,
    undefined,
    Textures.Glass,
    true
  );

  // Register blocks

  for (const [key, block] of Object.entries(Blocks)) {
    const index = VoxelTypeIdToIndex[VoxelTypeKeyToId[key as VoxelTypeKey]];
    const augmentedBlock = { ...block };
    if (!block) continue;

    // Register mesh for mesh blocks
    if (block.type === NoaBlockType.MESH) {
      const texture = Array.isArray(block.material)
        ? block.material[0]
        : block.material;
      if (texture === null) {
        throw new Error("Can't create a plant block without a material");
      }
      const mesh = createMeshBlock(
        noa,
        scene,
        texture,
        key,
        augmentedBlock.frames
      );
      augmentedBlock.blockMesh = mesh;
      delete augmentedBlock.material;
    }

    noa.registry.registerBlock(index, augmentedBlock);
  }

  function setBlock(coord: VoxelCoord | number[], block: Entity) {
    const index = VoxelTypeIdToIndex[block];
    if ("length" in coord) {
      noa.setBlock(index, coord[0], coord[1], coord[2]);
    } else {
      noa.setBlock(index, coord.x, coord.y, coord.z);
    }
  }

  noa.world.on(
    "worldDataNeeded",
    function (id: any, data: any, x: any, y: any, z: any) {
      // `id` - a unique string id for the chunk
      // `data` - an `ndarray` of voxel ID data (see: https://github.com/scijs/ndarray)
      // `x, y, z` - world coords of the corner of the chunk
      if (y < -MIN_HEIGHT) {
        noa.world.setChunkData(id, data, undefined);
        return;
      }
      for (let i = 0; i < data.shape[0]; i++) {
        for (let j = 0; j < data.shape[1]; j++) {
          for (let k = 0; k < data.shape[2]; k++) {
            const ecsBlockType =
              VoxelTypeIdToIndex[
                api.getEcsVoxelAtPosition({
                  x: x + i,
                  y: y + j,
                  z: z + k,
                }) as string
              ];
            if (ecsBlockType !== undefined) {
              data.set(i, j, k, ecsBlockType);
            } else {
              const blockType =
                VoxelTypeIdToIndex[
                  api.getTerrainBlockAtPosition({
                    x: x + i,
                    y: y + j,
                    z: z + k,
                  }) as string
                ];
              data.set(i, j, k, blockType);
            }
          }
        }
      }
      noa.world.setChunkData(id, data, undefined);
    }
  );

  const { glow } = setupScene(noa);

  // Change block targeting mechanism
  noa.blockTargetIdCheck = function (index: number) {
    const key = VoxelTypeIndexToKey[index];
    return key != null && key != "Air" && !Blocks[key]?.fluid;
  };
  return { noa, setBlock, glow };
}

function customizePlayerMovement(noa: Engine) {
  // Note: if you want to write very specific movement overrides, read this: https://github.com/fenomas/noa/issues/147
  // noa.entities.removeComponent(noa.playerEntity, noa.entities.names.movement)
  // noa.entities.addComponent(noa.playerEntity, newMovementComponent)

  // Make it so that players can still control their movement while in the air
  // why? because it feels weird when players lose control of their character: https://www.reddit.com/r/gamedev/comments/j3iigd/why_moving_in_the_air_after_jumping_in_games/
  noa.ents.getMovement(1).airMoveMult = 20;
  noa.ents.getMovement(1).standingFriction = 100;
}
