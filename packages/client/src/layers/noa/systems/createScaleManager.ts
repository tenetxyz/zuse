import { noaOptions } from "../setup/setupNoaEngine";
import { Layers } from "../../../types";
import { World, markAllChunksInvalid } from "noa-engine/src/lib/world";
// import { markAllChunksInvalid } from "noa-engine";

// The proper way to change the scale is to use a new worldname:
// we are not calling invalidateChunksInBox (or the deprecated world.invalidateAllChunks) because using the world name is the proper way to do it
// https://github.com/fenomas/noa/commit/095f42c15aa5b1832739b647523ee620f3606400

const worldScales = new Map<string, World>(); // worldName -> world

export const increaseScale = () => {};

export const decreaseScale = (layers: Layers) => {
  const {
    noa: { noa },
  } = layers;
  // doesn't work
  //   noa.world.worldName = "hi"; //
  // noa.world = new World(noa, noaOptions);
  markAllChunksInvalid(noa.world);
};

// const markAllChunksInvalid = (world: World) => {
//   world._chunksInvalidated.copyFrom(world._chunksKnown);
//   world._chunksToRemove.empty();
//   world._chunksToRequest.empty();
//   world._chunksToMesh.empty();
//   world._chunksToMeshFirst.empty();
//   sortQueueByDistanceFrom(world, world._chunksInvalidated);
// };
