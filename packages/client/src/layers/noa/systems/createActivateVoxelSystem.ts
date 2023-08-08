import { SyncState } from "@latticexyz/network";
import { defineComponentSystem, defineEnterSystem, getComponentValueStrict, Has } from "@latticexyz/recs";
import { awaitStreamValue } from "@latticexyz/utils";
import { NetworkLayer } from "../../network";
import { NoaLayer, VoxelVariantNoaDef } from "../types";
import { toast } from "react-toastify";
import { getNftStorageLink } from "../constants";
import { abiDecode } from "@/utils/encodeOrDecode";
import { removeTrailingNulls } from "@/utils/encodeOrDecode";

export async function createActivateVoxelSystem(network: NetworkLayer, noaLayer: NoaLayer) {
  const {
    world,
    components: { VoxelActivated },
    playerAddress,
  } = network;

  defineComponentSystem(world, VoxelActivated, (update) => {
    if (update.value[0] === undefined) {
      return;
    }
    if (update.entity === playerAddress) {
      const voxelActivatedData = update.value[0];
      const activateMsg = removeTrailingNulls(voxelActivatedData.message);
      if (activateMsg.length > 0) {
        toast(`Activated voxel message: ${activateMsg}`);
      }
    }
  });
}
