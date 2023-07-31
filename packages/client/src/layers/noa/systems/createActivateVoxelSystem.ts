import { SyncState } from "@latticexyz/network";
import { defineComponentSystem, defineEnterSystem, getComponentValueStrict, Has } from "@latticexyz/recs";
import { awaitStreamValue } from "@latticexyz/utils";
import { NetworkLayer } from "../../network";
import { NoaLayer, VoxelVariantNoaDef } from "../types";
import { toast } from "react-toastify";
import { getNftStorageLink } from "../constants";
import { abiDecode } from "../../../utils/abi";

export async function createActivateVoxelSystem(network: NetworkLayer, noaLayer: NoaLayer) {
  const {
    world,
    components: { LoadingState, VoxelActivated },
    playerEntity,
  } = network;
  const { noa } = noaLayer;

  // Loading state flag
  let live = false;
  awaitStreamValue(LoadingState.update$, ({ value }) => value[0]?.state === SyncState.LIVE).then(() => (live = true));

  defineComponentSystem(world, VoxelActivated, (update) => {
    if (update.value[0] === undefined) {
      return;
    }
    if (update.entity === playerEntity) {
      toast(`Activated voxel message: ${voxelActivatedData.message}`);
    }
  });
}