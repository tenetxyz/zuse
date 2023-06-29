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
        setMovementState(moveState, inputState, camHeading);
      }
    },
  };
}

/**
 * @param state MovementState
 * @param inputs InputState
 * @param camHeading number
 */

function setMovementState(state: IMovementState, inputs: InputState, camHeading: number): void {
  // if the player is currently jumping and the previous state it wasn't jumping
  if (!!inputs.jump && state.isJumpHeld === false) {
    state.isJumpPressed = true;
  } else {
    state.isJumpPressed = false;
  }
  state.isJumpHeld = !!inputs.jump;
  state.isCrouching = !!inputs.crouch;

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
