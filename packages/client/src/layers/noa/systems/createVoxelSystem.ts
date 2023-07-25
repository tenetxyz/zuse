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
    storeCache,
  } = networkLayer;

  // Loading state flag
  let live = false;
  awaitStreamValue(LoadingState.update$, ({ value }) => value[0]?.state === SyncState.LIVE).then(() => (live = true));

  defineComponentSystem(world, VoxelType, async (update) => {
    if (!live) return;
    if (!update.value[0] || !update.value[1]) return;
    const position = storeCache.tables.Position.get({ entity: update.entity, scale: getWorldScale(noa) });
    if (!position) return; // if there's no position, the voxel is not in the world. so no need to display it
    setVoxel(position, update.value[0].voxelVariantId);
  });

  // "Exit system"
  defineComponentSystem(world, Position, async ({ value }) => {
    if (!live) return;
    if (!value[0] && value[1]) {
      const voxel = getVoxelAtPosition(value[1], getWorldScale(noa));
      setVoxel(value[1], voxel.voxelVariantTypeId);
    }
  });

  // "Enter system"
  defineEnterSystem(world, [Has(Position), Has(VoxelType)], (update) => {
    if (!live) return;
    const position = storeCache.tables.Position.get({ entity: update.entity, scale: getWorldScale(noa) });
    const voxel = getVoxelAtPosition(position, getWorldScale(noa));
    setVoxel(position, voxel.voxelVariantTypeId);
  });
}
