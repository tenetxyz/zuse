import { SyncState } from "@latticexyz/network";
import { getComponentValueStrict, hasComponent } from "@latticexyz/recs";
import { awaitStreamValue } from "@latticexyz/utils";
import { NetworkLayer } from "../../network";
import { GRAVITY_MULTIPLIER } from "../constants";
import { MINING_VOXEL_COMPONENT } from "../engine/components/miningVoxelComponent";
import { setNoaPosition } from "../engine/components/utils";
import { NoaLayer } from "../types";
import { calculateParentCoord, getWorldScale } from "@/utils/coord";
import { TILE_Y } from "@/layers/network/api/terrain/occurrence";

export function createSpawnPlayerSystem(network: NetworkLayer, context: NoaLayer) {
  const {
    noa,
    SingletonEntity,
    components: { LocalPlayerPosition },
  } = context;

  const {
    streams: { doneSyncing$ },
  } = network;

  awaitStreamValue(doneSyncing$, (isDoneSyncing) => isDoneSyncing).then(() => {
    noa.entities.addComponentAgain(noa.playerEntity, MINING_VOXEL_COMPONENT, {});

    // Reset gravity once world is loaded
    const body = noa.ents.getPhysics(1)?.body;
    if (body) body.gravityMultiplier = GRAVITY_MULTIPLIER;

    if (hasComponent(LocalPlayerPosition, SingletonEntity)) {
      setNoaPosition(noa, noa.playerEntity, getComponentValueStrict(LocalPlayerPosition, SingletonEntity));
    } else {
      const spawn_point = calculateParentCoord({ x: 0, y: TILE_Y + 1, z: 0 }, getWorldScale(noa));
      setNoaPosition(noa, noa.playerEntity, spawn_point);
    }
  });
}
