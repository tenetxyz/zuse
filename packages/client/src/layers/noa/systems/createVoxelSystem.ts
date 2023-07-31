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
    contractComponents: { VoxelType, Position },
    api: { getVoxelAtPosition },
    streams: { doneSyncing$ },
  } = networkLayer;

  let isDoneSyncingWorlds = false;
  awaitStreamValue(doneSyncing$, (isDoneSyncing) => isDoneSyncing).then(() => {
    isDoneSyncingWorlds = true;
  });

  defineComponentSystem(world, VoxelType, async (update) => {
    if (!isDoneSyncingWorlds) return;
    // if the new type is none, or the old type is none, return
    // Basically, the main part of this function runs when the VoxelType variant has changed
    // Actually, I've also noticed that this function also runs when we place a voxel into the world
    // Maybe it's because we get two updates for VoxelType: one when the entity is created, and one when it's placed?
    if (!update.value[0] || !update.value[1]) return;
    const position = getComponentValue(Position, update.entity);
    // const entity = to64CharAddress("0x" + update.entity);
    // const position = liveStoreCache.Position.get({ entity, scale: getWorldScale(noa) });
    if (!position) return; // if there's no position, the voxel is not in the world. so no need to display it
    const entityKey = update.entity;
    const worldScale = getWorldScale(noa);
    if (!isEntityInCurrentScale(entityKey, worldScale)) {
      return;
    }
    setVoxel(position, update.value[0].voxelVariantId);
  });

  // "Exit system"
  defineComponentSystem(world, Position, async ({ value }) => {
    if (!isDoneSyncingWorlds) return;
    if (!value[0] && value[1]) {
      const voxel = getVoxelAtPosition(value[1], getWorldScale(noa));
      setVoxel(value[1], voxel.voxelVariantTypeId);
    }
  });

  // "Enter system"
  defineEnterSystem(world, [Has(Position), Has(VoxelType)], (update) => {
    if (!isDoneSyncingWorlds) return;
    const entityKey = update.entity;
    const worldScale = getWorldScale(noa);
    const position = getComponentValueStrict(Position, entityKey);
    const voxel = getVoxelAtPosition(position, worldScale); // TODO: do we even need this funciton? we already have the entity from teh update, so it probably isn't a terrain block. I think we can just use getVoxelType for the given entity (after getting its position)
    setVoxel(position, voxel.voxelVariantTypeId);
  });

  const isEntityInCurrentScale = (entityKey: string, scale: number) => {
    const [_scaleInHexadecimal, entity] = entityKey.split(":");
    return _scaleInHexadecimal == to64CharAddress("0x" + scale);
  };
}
