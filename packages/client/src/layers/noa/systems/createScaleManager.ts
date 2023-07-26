import { noaOptions } from "../setup/setupNoaEngine";
import { Layers } from "../../../types";
import { World, markAllChunksInvalid } from "noa-engine/src/lib/world";
import { getVoxelAtPosition } from "@tenetxyz/layers/network/api";
import { voxelTypeToEntity } from "../types";
import { stringToVoxelCoord, voxelCoordToString } from "../../../utils/coord";
import { toast } from "react-toastify";
// import { markAllChunksInvalid } from "noa-engine";

// The proper way to change the scale is to use a new worldname:
// we are not calling invalidateChunksInBox (or the deprecated world.invalidateAllChunks) because using the world name is the proper way to do it
// https://github.com/fenomas/noa/commit/095f42c15aa5b1832739b647523ee620f3606400

export const setScale = (layers: Layers, scaleDiff: number) => {
  const {
    noa: { noa },
  } = layers;
  const currentWorldScale = parseInt(noa.worldName);
  const newWorldScale = currentWorldScale + scaleDiff;
  if (newWorldScale === 0) {
    toast("you can't go any smaller than level 1!");
    return;
  }
  toast("changing scale to " + newWorldScale);

  // Note: There is a function in world.js that is a tick loop. This will check to see if the function has changed and properly update the world.
  // noa automatically resets all chunks and reloads them when the worldName changes!
  noa.worldName = newWorldScale.toString();
};
