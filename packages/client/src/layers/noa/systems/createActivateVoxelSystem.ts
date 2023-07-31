import { SyncState } from "@latticexyz/network";
import { defineComponentSystem, defineEnterSystem, getComponentValueStrict, Has } from "@latticexyz/recs";
import { awaitStreamValue } from "@latticexyz/utils";
import { NetworkLayer } from "../../network";
import { NoaLayer, VoxelVariantNoaDef } from "../types";
import { getNftStorageLink } from "../constants";
import { abiDecode } from "../../../utils/abi";

export async function createActivateVoxelSystem(network: NetworkLayer, noaLayer: NoaLayer) {
  const {
    world,
    components: { LoadingState, ActivatedVoxel },
  } = network;
  const { noa } = noaLayer;

  // Loading state flag
  let live = false;
  awaitStreamValue(LoadingState.update$, ({ value }) => value[0]?.state === SyncState.LIVE).then(() => (live = true));

  defineComponentSystem(world, ActivatedVoxel, (update) => {
    console.log("ActivatedVoxel");
    console.log(update);
  });
}
