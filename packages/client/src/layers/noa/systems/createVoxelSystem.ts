import { SyncState } from "@latticexyz/network";
import {
  defineComponentSystem,
  defineEnterSystem,
  getComponentValue,
  getComponentValueStrict,
  Has,
} from "@latticexyz/recs";
import { awaitStreamValue } from "@latticexyz/utils";
import { NetworkLayer } from "../../network";
import { NoaLayer } from "../types";
import { getWorldScale } from "../../../utils/coord";
import { to64CharAddress } from "../../../utils/entity";

export async function createVoxelSystem(networkLayer: NetworkLayer, noaLayer: NoaLayer) {
  const {
    api: { setVoxel },
    noa,
  } = noaLayer;

  const {
    world,
    components: { LoadingState },
    contractComponents: { VoxelType, Position },
    api: { getVoxelAtPosition },
    liveStoreCache,
  } = networkLayer;

  // Loading state flag
  let live = false;
  awaitStreamValue(LoadingState.update$, ({ value }) => value[0]?.state === SyncState.LIVE).then(() => (live = true));

  defineComponentSystem(world, VoxelType, async (update) => {
    console.log("voxel type update");
    if (!live) return;
    if (!update.value[0] || !update.value[1]) return;
    const position = getComponentValue(Position, update.entity);
    // const entity = to64CharAddress("0x" + update.entity);
    // const position = liveStoreCache.Position.get({ entity, scale: getWorldScale(noa) });
    if (!position) return; // if there's no position, the voxel is not in the world. so no need to display it
    setVoxel(position, update.value[0].voxelVariantId);
  });

  // "Exit system"
  defineComponentSystem(world, Position, async ({ value }) => {
    console.log("exit called");
    if (!live) return;
    if (!value[0] && value[1]) {
      const voxel = getVoxelAtPosition(value[1], getWorldScale(noa));
      setVoxel(value[1], voxel.voxelVariantTypeId);
    }
  });

  // "Enter system"
  defineEnterSystem(world, [Has(Position), Has(VoxelType)], (update) => {
    console.log("enter called");
    if (!live) return;
    // const entity = to64CharAddress("0x" + update.entity);
    const position = getComponentValueStrict(Position, update.entity);
    // const position = liveStoreCache.Position.get({ entity, scale: getWorldScale(noa) });
    const voxel = getVoxelAtPosition(position, getWorldScale(noa)); // TODO: do we even need this funciton? we already have the entity from teh update, so it probably isn't a terrain block. I think we can just use getVoxelType for the given entity (after getting its position)
    setVoxel(position, voxel.voxelVariantTypeId);
  });
}
