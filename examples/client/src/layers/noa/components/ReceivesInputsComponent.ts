// This file was copied over from noa: https://github.com/fenomas/noa/blob/master/src/components/receivesInputs.js
// The reason why was we needed to modify it to support flying.
import { Engine } from "noa-engine";
import { IMovementState } from "./MovementComponent";

export const RECEIVES_INPUTS_COMPONENT_NAME = "receivesInputs";

interface InputState {
  [key: string]: boolean;
}

interface SystemEntity {
  __id: number;
}

interface SystemState {
  [key: string]: SystemEntity;
}

interface System {
  name: string;
  order: number;
  state: {};
  onAdd: null | (() => void);
  onRemove: null | (() => void);
  system: (dt: number, states: SystemState[]) => void;
}

export default function (noa: any): System {
  return {
    name: RECEIVES_INPUTS_COMPONENT_NAME,
    order: 20,
    state: {},
    onAdd: null,
    onRemove: null,
    system: function inputProcessor(dt: number, states: SystemState[]) {
      const ents = noa.entities;
      const inputState = noa.inputs.state;
      let camHeading = noa.camera.heading;

      for (let i = 0; i < states.length; i++) {
        const state = states[i];
        const moveState = ents.getMovement(state.__id);
        setMovementState(noa, moveState, inputState, camHeading);
      }
    },
  };
}

/**
 * @param state MovementState
 * @param inputs InputState
 * @param camHeading number
 */

function setMovementState(noa: Engine, state: IMovementState, inputs: InputState, camHeading: number): void {
  // this means: if the player is currently jumping and the previous frame it wasn't jumping
  // then the user pressed the jump button on this frame
  state.isJumpPressed = inputs.jump && !state.isJumpHeld && noa.container.hasPointerLock;

  state.isJumpHeld = inputs.jump && noa.container.hasPointerLock;
  state.isCrouching = inputs.crouch && noa.container.hasPointerLock; // only crouch if the mouse is locked. This is so mac users can screenshot

  const fb = inputs.forward ? (inputs.backward ? 0 : 1) : inputs.backward ? -1 : 0;
  const rl = inputs.right ? (inputs.left ? 0 : 1) : inputs.left ? -1 : 0;

  if ((fb | rl) === 0) {
    state.isRunning = false;
  } else {
    state.isRunning = true;
    if (fb) {
      if (fb == -1) camHeading += Math.PI;
      if (rl) {
        camHeading += (Math.PI / 4) * fb * rl;
      }
    } else {
      camHeading += (rl * Math.PI) / 2;
    }
    state.heading = camHeading;
  }
}