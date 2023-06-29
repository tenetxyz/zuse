import { SyncState } from "@latticexyz/network";
import { getComponentValueStrict, hasComponent } from "@latticexyz/recs";
import { awaitStreamValue } from "@latticexyz/utils";
import { NetworkLayer } from "../../network";
import { GRAVITY_MULTIPLIER, SPAWN_POINT } from "../constants";
import { MINING_VOXEL_COMPONENT } from "../engine/components/miningVoxelComponent";
import { setNoaPosition } from "../engine/components/utils";
import { NoaLayer } from "../types";

export function createSpawnPlayerSystem(network: NetworkLayer, context: NoaLayer) {
  const {
    noa,
    SingletonEntity,
    components: { LocalPlayerPosition },
  } = context;

  const {
    components: { LoadingState },
  } = network;

  awaitStreamValue(LoadingState.update$, ({ value }) => value[0]?.state === SyncState.LIVE).then(() => {
    noa.entities.addComponentAgain(noa.playerEntity, MINING_VOXEL_COMPONENT, {});

    // Reset gravity once world is loaded
    const body = noa.ents.getPhysics(1)?.body;
    if (body) body.gravityMultiplier = GRAVITY_MULTIPLIER;

    if (hasComponent(LocalPlayerPosition, SingletonEntity)) {
      setNoaPosition(noa, noa.playerEntity, getComponentValueStrict(LocalPlayerPosition, SingletonEntity));
    } else {
      setNoaPosition(noa, noa.playerEntity, SPAWN_POINT);
    }
  });
}
