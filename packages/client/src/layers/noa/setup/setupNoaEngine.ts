/* eslint-disable @typescript-eslint/ban-ts-comment */
import { Engine } from "noa-engine";
// add a mesh to represent the player, and scale it, etc.
import "@babylonjs/core/Meshes/Builders/boxBuilder";
import * as BABYLON from "@babylonjs/core";
import { VoxelCoord } from "@latticexyz/utils";
import { Textures, Voxels } from "../constants";
import { VoxelTypeIdToIndex, VoxelTypeKeyToId } from "../../network";
import { Entity } from "@latticexyz/recs";
import { NoaBlockType } from "../types";
import { createVoxelMesh } from "./utils";
import { VoxelTypeIndexToKey, VoxelTypeKey } from "../../network/constants";
import { setupScene } from "../engine/setupScene";
import {
  CHUNK_RENDER_DISTANCE,
  CHUNK_SIZE,
  MIN_HEIGHT,
  SKY_COLOR,
} from "./constants";

export interface API {
  getTerrainVoxelTypeAtPosition: (coord: VoxelCoord) => Entity;
  getEcsVoxelTypeAtPosition: (coord: VoxelCoord) => Entity | undefined;
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
  const textures = Object.values(Voxels).reduce<string[]>(
    (materials, voxel) => {
      if (!voxel || !voxel.material) return materials;
      const voxelMaterials = (
        Array.isArray(voxel.material) ? voxel.material : [voxel.material]
      ) as string[];
      if (voxelMaterials) materials.push(...voxelMaterials);
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

  // Register voxels

  for (const [key, voxel] of Object.entries(Voxels)) {
    const index = VoxelTypeIdToIndex[VoxelTypeKeyToId[key as VoxelTypeKey]];
    const augmentedVoxel = { ...voxel };
    if (!voxel) continue;

    // Register mesh for mesh voxels
    if (voxel.type === NoaBlockType.MESH) {
      const texture = Array.isArray(voxel.material)
        ? voxel.material[0]
        : voxel.material;
      if (texture === null) {
        throw new Error("Can't create a plant voxel without a material");
      }
      const mesh = createVoxelMesh(
        noa,
        scene,
        texture,
        key,
        augmentedVoxel.frames
      );
      augmentedVoxel.blockMesh = mesh;
      delete augmentedVoxel.material;
    }

    noa.registry.registerBlock(index, augmentedVoxel);
  }

  function setVoxel(coord: VoxelCoord | number[], voxel: Entity) {
    const index = VoxelTypeIdToIndex[voxel];
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
            const ecsVoxelTypeIndex =
              VoxelTypeIdToIndex[
                api.getEcsVoxelTypeAtPosition({
                  x: x + i,
                  y: y + j,
                  z: z + k,
                }) as string
              ];
            if (ecsVoxelTypeIndex !== undefined) {
              data.set(i, j, k, ecsVoxelTypeIndex);
            } else {
              const voxelTypeIndex =
                VoxelTypeIdToIndex[
                  api.getTerrainVoxelTypeAtPosition({
                    x: x + i,
                    y: y + j,
                    z: z + k,
                  }) as string
                ];
              data.set(i, j, k, voxelTypeIndex);
            }
          }
        }
      }
      noa.world.setChunkData(id, data, undefined);
    }
  );

  const { glow } = setupScene(noa);

  // Change voxel targeting mechanism
  noa.blockTargetIdCheck = function (index: number) {
    const key = VoxelTypeIndexToKey[index];
    return key != null && key != "Air" && !Voxels[key]?.fluid;
  };
  return { noa, setVoxel, glow };
}

function customizePlayerMovement(noa: Engine) {
  // Note: if you want to write very specific movement overrides, read this: https://github.com/fenomas/noa/issues/147
  // noa.entities.removeComponent(noa.playerEntity, noa.entities.names.movement)
  // noa.entities.addComponent(noa.playerEntity, newMovementComponent)

  // Make it so that players can still control their movement while in the air
  // why? because it feels weird when players lose control of their character: https://www.reddit.com/r/gamedev/comments/j3iigd/why_moving_in_the_air_after_jumping_in_games/
  noa.ents.getMovement(1).airMoveMult = 0.3; // Note: if you sent this value too high, then players will have a hard time making short jumps (it's more important than long jumps, cause it gives them better control)
  noa.ents.getMovement(1).standingFriction = 100;
}
