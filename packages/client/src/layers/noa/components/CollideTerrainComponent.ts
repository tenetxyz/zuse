import { GRAVITY_MULTIPLIER } from "../constants";

interface State {
  callback: ((impulse: any, eid: number) => void) | null;
}

interface Entity {
  body: {
    onCollide: ((impulse: any) => void) | null;
  };
}
export const COLLIDE_TERRAIN_COMPONENT_NAME = "collideTerrain";

export default function (noa: any) {
  return {
    name: COLLIDE_TERRAIN_COMPONENT_NAME,

    order: 0,

    state: {
      callback: null,
    } as State,

    onAdd(entityId: number, state: State) {
      // add collide handler for physics engine to call
      const ents = noa.entities;
      if (ents.hasPhysics(entityId)) {
        const body = ents.getPhysics(entityId).body;
        body.onCollide = function bodyOnCollide(impulse: any) {
          if (entityId === noa.playerEntity) {
            const playerImpulse = impulse as Float64Array;
            const playerBody = ents.getPhysicsBody(entityId);
            const isFlying = playerBody.gravityMultiplier === 0;
            if (playerImpulse[1] > 0 && isFlying) {
              // the player was flying then crouched and hit the floor. Stop flying.
              playerBody.gravityMultiplier = GRAVITY_MULTIPLIER;
            }
          }
          const cb = noa.ents.getCollideTerrain(entityId)?.callback;
          if (cb) cb(impulse, entityId);
        };
      }
    },

    onRemove(eid: number, state: State) {
      const ents = noa.entities;
      if (ents.hasPhysics(eid)) {
        ents.getPhysics(eid).body.onCollide = null;
      }
    },
  };
}
