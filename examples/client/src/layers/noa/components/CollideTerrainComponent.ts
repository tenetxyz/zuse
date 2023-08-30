// This file is mostly copied from the noa engine
// https://github.com/fenomas/noa/blob/master/src/components/collideTerrain.js
// However, we needed to change it, to incorporate flying
import { GRAVITY_MULTIPLIER } from "../constants";
import { isFlying } from "./MovementComponent";

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
          // We added this this code to turn off flying mode when the player collide with the floor
          if (entityId === noa.playerEntity) {
            const playerImpulse = impulse as Float32Array;
            const playerBody = ents.getPhysicsBody(entityId);
            const playerCollidesWithBlockBelow = playerImpulse[1] > 0;
            if (playerCollidesWithBlockBelow && isFlying(playerBody)) {
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