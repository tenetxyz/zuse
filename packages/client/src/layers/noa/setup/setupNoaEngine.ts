/* eslint-disable @typescript-eslint/ban-ts-comment */
import { Engine } from "noa-engine";
// add a mesh to represent the player, and scale it, etc.
import "@babylonjs/core/Meshes/Builders/boxBuilder";
import * as BABYLON from "@babylonjs/core";
import { VoxelCoord } from "@latticexyz/utils";
import { NetworkLayer } from "../../network";
import { NoaBlockType, voxelTypeDataKeyToVoxelVariantDataKey, voxelVariantKeyStringToKey } from "../types";
import { createVoxelMesh } from "./utils";
import { voxelVariantDataKeyToString, VoxelVariantDataKey } from "../types";
import { setupScene } from "../engine/setupScene";
import { CHUNK_RENDER_DISTANCE, CHUNK_SIZE, MIN_HEIGHT, SKY_COLOR } from "./constants";
import { VoxelVariantDataValue } from "../types";
import { AIR_ID } from "../../network/api/terrain/occurrence";
import MovementComponent, { MOVEMENT_COMPONENT_NAME } from "../components/MovementComponent";
import ReceiveInputsComponent, { RECEIVES_INPUTS_COMPONENT_NAME } from "../components/ReceivesInputsComponent";
import CollideTerrainComponent, { COLLIDE_TERRAIN_COMPONENT_NAME } from "../components/CollideTerrainComponent";
import PositionComponent, { POSITION_COMPONENT_NAME } from "../components/PositionComponent";

export const DEFAULT_BLOCK_TEST_DISTANCE = 7;

export function setupNoaEngine(network: NetworkLayer) {
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
    blockTestDistance: DEFAULT_BLOCK_TEST_DISTANCE,
    playerHeight: 1.85,
    playerWidth: 0.6,
    playerAutoStep: 1,
    clearColor: SKY_COLOR,
    useAO: true,
    AOmultipliers: [0.93, 0.8, 0.5],
    reverseAOmultiplier: 1.0,
    preserveDrawingBuffer: true,
  };
  const {
    api: { getTerrainVoxelTypeAtPosition, getEcsVoxelTypeAtPosition },
    voxelTypes: { VoxelVariantData, VoxelVariantIndexToKey, VoxelVariantDataSubscriptions },
  } = network;

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

  function voxelMaterialSubscription(voxelVariantKey: VoxelVariantDataKey, voxelVariantData: VoxelVariantDataValue) {
    const data = voxelVariantData.data;
    if (!data) return;
    const voxelMaterials = (Array.isArray(data.material) ? data.material : [data.material]) as string[];
    for (const texture of voxelMaterials) {
      console.log("Registering material", texture);
      noa.registry.registerMaterial(texture, undefined, texture);
    }
  }

  function voxelBlockSubscription(voxelVariantKey: VoxelVariantDataKey, voxelVariantData: VoxelVariantDataValue) {
    const index = voxelVariantData.index;
    const data = voxelVariantData.data;
    const voxel = data;
    const voxelTypeKeyStr = voxelVariantDataKeyToString(voxelVariantKey);

    const augmentedVoxel = { ...voxel };
    if (!voxel) return;

    // Register mesh for mesh voxels
    if (voxel.type === NoaBlockType.MESH) {
      const texture = Array.isArray(voxel.material) ? voxel.material[0] : voxel.material;
      if (texture === null) {
        throw new Error("Can't create a plant voxel without a material");
      }
      const mesh = createVoxelMesh(noa, scene, texture, voxelTypeKeyStr, augmentedVoxel.frames);
      augmentedVoxel.blockMesh = mesh;
      delete augmentedVoxel.material;
    }

    console.log("Registering block", index, augmentedVoxel);
    noa.registry.registerBlock(index, augmentedVoxel);
  }

  VoxelVariantDataSubscriptions.push(voxelMaterialSubscription);
  VoxelVariantDataSubscriptions.push(voxelBlockSubscription);

  // initial run
  for (const [voxelVariantKey, voxelVariantData] of VoxelVariantData.entries()) {
    const voxelVariantDataKey = voxelVariantKeyStringToKey(voxelVariantKey);
    voxelMaterialSubscription(voxelVariantDataKey, voxelVariantData);
    voxelBlockSubscription(voxelVariantDataKey, voxelVariantData);
  }

  // Register voxels

  function setVoxel(coord: VoxelCoord | number[], voxelVariantDataKey: VoxelVariantDataKey) {
    const index = VoxelVariantData.get(voxelVariantDataKeyToString(voxelVariantDataKey))?.index;
    if ("length" in coord) {
      noa.setBlock(index, coord[0], coord[1], coord[2]);
    } else {
      noa.setBlock(index, coord.x, coord.y, coord.z);
    }
  }

  noa.world.on("worldDataNeeded", function (id: any, data: any, x: any, y: any, z: any) {
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
          const ecsVoxelType = getEcsVoxelTypeAtPosition({
            x: x + i,
            y: y + j,
            z: z + k,
          });
          let ecsVoxelTypeIndex = undefined;
          if (ecsVoxelType !== undefined) {
            ecsVoxelTypeIndex = VoxelVariantData.get(
              voxelVariantDataKeyToString({
                voxelVariantNamespace: ecsVoxelType.voxelVariantNamespace,
                voxelVariantId: ecsVoxelType.voxelVariantId,
              })
            )?.index;
          }
          if (ecsVoxelTypeIndex !== undefined) {
            data.set(i, j, k, ecsVoxelTypeIndex);
          } else {
            const terrainVoxelType = getTerrainVoxelTypeAtPosition({
              x: x + i,
              y: y + j,
              z: z + k,
            });
            const voxelTypeIndex = VoxelVariantData.get(
              voxelVariantDataKeyToString(voxelTypeDataKeyToVoxelVariantDataKey(terrainVoxelType))
            )?.index;
            data.set(i, j, k, voxelTypeIndex);
          }
        }
      }
    }
    noa.world.setChunkData(id, data, undefined);
  });

  const { glow } = setupScene(noa);

  // Change voxel targeting mechanism
  noa.blockTargetIdCheck = function (index: number) {
    const key = VoxelVariantIndexToKey.get(index);
    return (
      key != null &&
      key.voxelVariantId != AIR_ID &&
      !VoxelVariantData.get(voxelVariantDataKeyToString(key))?.data?.fluid
    );
  };
  return { noa, setVoxel, glow };
}

function customizePlayerMovement(noa: Engine) {
  // use our own custom components to support flying
  useCustomComponents(noa, PositionComponent, POSITION_COMPONENT_NAME, {});
  noa.entities.getPositionData = noa.ents.getStateAccessor(POSITION_COMPONENT_NAME); // we need to update this getter because noa's internal functions use this getter
  noa.entities.hasPosition = noa.ents.getComponentAccessor(POSITION_COMPONENT_NAME); // we need to update this getter because noa's internal functions use this getter

  useCustomComponents(noa, MovementComponent, MOVEMENT_COMPONENT_NAME, { maxJumps: 2 });
  noa.entities.getMovement = noa.ents.getStateAccessor(MOVEMENT_COMPONENT_NAME); // we need to update this getter because noa's internal functions use this getter
  useCustomComponents(noa, ReceiveInputsComponent, RECEIVES_INPUTS_COMPONENT_NAME, {});
  useCustomComponents(noa, CollideTerrainComponent, COLLIDE_TERRAIN_COMPONENT_NAME, {});

  // Make it so that players can still control their movement while in the air
  // why? because it feels weird when players lose control of their character: https://www.reddit.com/r/gamedev/comments/j3iigd/why_moving_in_the_air_after_jumping_in_games/
  const movementComponent = noa.entities.getMovement(noa.playerEntity);
  movementComponent.airMoveMult = 0.3; // Note: if you sent this value too high, then players will have a hard time making short jumps (it's more important than long jumps, cause it gives them better control)
  movementComponent.standingFriction = 100;
}

// I learned how to add custom components to noa via this thread: https://github.com/fenomas/noa/issues/147
// NOTE: componentName MUST be the same as the name of the default component (so the correct component is removed)
const useCustomComponents = (noa: Engine, Component: any, componentName: string, args: any) => {
  let existingComponentValues = noa.ents.getStatesList(componentName);
  // clone this object array
  existingComponentValues = existingComponentValues.map((componentValue) => {
    return { ...componentValue };
  });

  // remove the default component before adding our modified version
  noa.entities.removeComponent(noa.playerEntity, noa.entities.names[componentName]);
  noa.entities.deleteComponent(componentName);

  // add our modified version
  noa.entities.names[componentName] = noa.entities.createComponent(Component(noa));
  // need to copy over the existing components
  existingComponentValues.forEach((componentValue) => {
    noa.entities.addComponent(componentValue.__id, componentName, componentValue);
  });
};
