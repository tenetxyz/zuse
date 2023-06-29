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

    onAdd(eid: number, state: State) {
      // add collide handler for physics engine to call
      const ents = noa.entities;
      if (ents.hasPhysics(eid)) {
        const body = ents.getPhysics(eid).body;
        body.onCollide = function bodyOnCollide(impulse: any) {
          if (eid === noa.playerEntity) {
            // console.log(noa.ents.getCollideTerrain(eid));
            const playerImpulse = impulse as Float64Array;
            const playerBody = ents.getPhysicsBody(eid);
            const isFlying = playerBody.gravityMultiplier === 0;
            if (playerImpulse[1] > 0 && isFlying) {
              // the player was flying then crouched and hit the floor. Stop flying.
              playerBody.gravityMultiplier = GRAVITY_MULTIPLIER;
            }
          }
          const cb = noa.ents.getCollideTerrain(eid)?.callback;
          if (cb) cb(impulse, eid);
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
