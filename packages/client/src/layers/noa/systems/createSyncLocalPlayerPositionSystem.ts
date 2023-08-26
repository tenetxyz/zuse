import { defineRxSystem, getComponentValueStrict, hasComponent, setComponent } from "@latticexyz/recs";
import { NetworkLayer } from "../../network";
import { NoaLayer } from "../types";
import { awaitStreamValue } from "@latticexyz/utils";

export function createSyncLocalPlayerPositionSystem(network: NetworkLayer, context: NoaLayer) {
  const {
    streams: { doneSyncing$ },
  } = network;
  const {
    components: { LocalPlayerPosition },
    SingletonEntity,
    streams: { slowPlayerPosition$ },
    world,
  } = context;

  let isDoneSyncingWorlds = false;
  awaitStreamValue(doneSyncing$, (isDoneSyncing) => isDoneSyncing).then(() => {
    isDoneSyncingWorlds = true;
  });

  defineRxSystem(world, slowPlayerPosition$, (pos) => {
    if (!isDoneSyncingWorlds) {
      return;
    }
    setComponent(LocalPlayerPosition, SingletonEntity, pos);
  });
}
