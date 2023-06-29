import vec3 from "gl-vec3";
import { RigidBody } from "noa-engine/dist/src/components/physics";
import { GRAVITY_MULTIPLIER } from "../constants";

export interface IMovementState {
  heading: number; // radians
  isRunning: boolean;
  isJumpHeld: boolean;

  // options
  runningSpeed: number;
  flyingSpeed: number;
  ascendAndDescendSpeed: number;
  jumpingInAirSpeed: number;
  runningFriction: number;
  standingFriction: number;

  // jumps
  jumpImpulse: number;
  jumpForce: number;
  jumpTimeMs: number; // ms
  maxAirJumps: number;
  isJumpPressed: boolean;

  canFly: boolean;
  isCrouching: boolean;

  // internal state
  _jumpCount: number;
  _currentjumpTimeMs: number;
  _lastJumpPressTimeMs: number;

  __id?: string;
}

export function MovementState(): IMovementState {
  return {
    heading: 0,
    isRunning: false,
    isJumpHeld: false,

    // options
    runningSpeed: 10,
    flyingSpeed: 17,
    ascendAndDescendSpeed: 15,
    jumpingInAirSpeed: 15,
    runningFriction: 0,
    standingFriction: 2,

    // jumps
    jumpImpulse: 10, // in physics, impulse is force * delta t
    jumpForce: 12,
    jumpTimeMs: 500, // This determines how long the jump force should be applied
    maxAirJumps: 1,
    isJumpPressed: false,

    canFly: true,
    isCrouching: false,

    // internal state
    _jumpCount: 0,
    _currentjumpTimeMs: 0,
    _lastJumpPressTimeMs: 0,
  };
}

interface IMovement {
  name: string;
  order: number;
  state: IMovementState;
  onAdd: null;
  onRemove: null;
  system(dt: number, states: IMovementState[]): void;
}

// Note: I am guessing this interface. It helps because it calms typescript down.
// I'm not sure why the RigidBody in noa doesn't have these types (but they are on the actual RigidBody object)
interface ExtendedRigidBody extends RigidBody {
  atRestY: () => number;
  applyForce: (force: number[]) => void; // the param is a vec3
  applyImpulse: (impulse: number[]) => void; // the param is a vec3
  _physBody: any;
}

export const MOVEMENT_COMPONENT_NAME = "movement";

export default function (noa: any): IMovement {
  return {
    name: MOVEMENT_COMPONENT_NAME,
    order: 30,
    state: MovementState(),
    onAdd: null,
    onRemove: null,
    system: function movementProcessor(dt: number, states: IMovementState[]) {
      const ents = noa.entities;
      for (let i = 0; i < states.length; i++) {
        const state = states[i];
        const phys = ents.getPhysics(state.__id);
        if (phys) applyMovementPhysics(dt, state, phys.body);
      }
    },
  };
}

const tempvec = vec3.create();
const tempvec2 = vec3.create();
const zeroVec = vec3.create();

function applyMovementPhysics(dt: number, state: IMovementState, body: ExtendedRigidBody) {
  // move implementation originally written as external module
  // see https://github.com/fenomas/voxel-fps-controller
  // for original code

  let isOnGround = body.atRestY() < 0;
  if (isOnGround) {
    state._jumpCount = 0;
  }

  exportMovementForcesToBody(state, body, dt, isOnGround);

  // apply movement forces if entity is moving, otherwise just friction
  let m: any = tempvec;
  let push: any = tempvec2;
  if (state.isRunning) {
    // todo: add crouch/sprint modifiers if needed
    // if (state.sprint) speed *= state.sprintMoveMult
    // if (state.crouch) speed *= state.crouchMoveMult
    let speed;
    if (isFlying(body)) {
      speed = state.flyingSpeed;
    } else {
      speed = state.runningSpeed;
    }
    vec3.set(m, 0, 0, speed);

    // rotate move vector to entity's heading
    vec3.rotateY(m, m, zeroVec, state.heading);

    // push vector to achieve desired speed & dir
    // following code to adjust 2D velocity to desired amount is patterned on Quake:
    // https://github.com/id-Software/Quake-III-Arena/blob/master/code/game/bg_pmove.c#L275
    vec3.sub(push, m, body.velocity);
    push[1] = 0; // the user's WASD movement shouldn't affect their Y velocity
    vec3.normalize(push, push); // IMPORTANT! we normalize the push vector before applying it

    // the len is the modulus of the vector I think. I think this is just an optimization
    const pushLen = vec3.len(push);
    if (isFlying(body)) {
      accelerateBodyToVelocityAtSpeed(push, body, state.flyingSpeed);
      return;
    } else if (isOnGround) {
      accelerateBodyToVelocityAtSpeed(push, body, state.jumpingInAirSpeed);
    } else {
      accelerateBodyToVelocityAtSpeed(push, body, state.runningSpeed);
    }

    // different friction when not moving
    // idea from Sonic: http://info.sonicretro.org/SPG:Running
    body.friction = state.runningFriction;
  } else {
    body.friction = state.standingFriction;
  }
}

const accelerateBodyToVelocityAtSpeed = (normalVec: number[], body: ExtendedRigidBody, speed: number) => {
  const diff = Math.abs(speed - normalVec.length);
  // const diff = speed - normalVec.length;
  // the math equation basically says:
  // the further you are from the flying speed (the diff variable), the larger our push should be
  vec3.scale(normalVec, normalVec, speed * (1 + (diff / speed) * 1.5));
  body.applyForce(normalVec);
};

const doublePressedJump = (state: IMovementState) => {
  const currentTimeMs = new Date().getTime();
  return state.isJumpPressed && state._lastJumpPressTimeMs + 400 > currentTimeMs; // checks that the last time we pressed jump was recent enough
};

export const isFlying = (body: RigidBody) => {
  return body.gravityMultiplier === 0;
};

const toggleFlying = (body: RigidBody) => {
  if (isFlying(body)) {
    // they are falling now
    body.gravityMultiplier = GRAVITY_MULTIPLIER;
    body.airDrag = 0.1;
    return; // we are now falling, so no need to jump
  } else {
    // they are flying now
    body.gravityMultiplier = 0;
    body.velocity[1] = 0; // reset their velocity so they stop falling
    body.airDrag = 0;
    return; // return. It's okay if we don't start going up until the next frame
  }
};

// This function accelerates the user to the desired speed.
// It applies a larger acceleration if the player is at a slower speed.
// Why not just set the player's velocity to the desired velocity?
// because it was very jarring and not pleasant
const accelerateToSpeed2 = (targetSpeed: number, body: RigidBody) => {
  // if the body isn't travelling in the right direction, then we want to accelerate it more
  if (body.velocity[1] * targetSpeed < 0) {
    return targetSpeed * 6;
  }
  if (Math.abs(body.velocity[1]) < 0.5 * Math.abs(targetSpeed)) {
    return targetSpeed * 2; // give it more acceleration if it's going slow
  }
  return targetSpeed;
};

const exportMovementForcesToBody = (
  state: IMovementState,
  body: ExtendedRigidBody,
  dt: number,
  isOnGround: boolean
) => {
  const canJump = isOnGround || state._jumpCount < state.maxAirJumps;

  if (isFlying(body)) {
    if (state.isCrouching) {
      // fly down
      body.applyForce([0, accelerateToSpeed2(-state.ascendAndDescendSpeed, body), 0]);
      return;
    } else if (state.isJumpHeld) {
      // fly up
      body.applyForce([0, accelerateToSpeed2(state.ascendAndDescendSpeed, body), 0]);
    } else {
      body.velocity[1] *= 0.5; // multiply velocity by 0.5 to gradually slow down
      if (!state.isRunning) {
        // we are flying and not pressing wasd. So stop moving
        // TODO: reduce velocity over time to 0
        body.velocity[0] *= 0.5;
        body.velocity[2] *= 0.5;
      }
    }
  }

  // 1) toggle flying if they can fly
  if (doublePressedJump(state) && state.canFly) {
    toggleFlying(body);
    state._lastJumpPressTimeMs = 0; // reset the last jump press time so we don't double jump when we press jump again
    return;
  }

  // 2) if they just pressed jump, start a jump
  // Note: isJumpPressed is only true on the frame the jump key is pressed
  if (state.isJumpPressed) {
    state._lastJumpPressTimeMs = new Date().getTime();
    if (isFlying(body)) {
      // just give them upwards velocity. do NOT give them a massive impulse like below
      // body.velocity[1] = 10;
      body.applyForce([0, 10, 0]);
      return;
    } else if (canJump) {
      // start new jump
      state._jumpCount++;
      state._currentjumpTimeMs = state.jumpTimeMs;
      body.applyImpulse([0, state.jumpImpulse, 0]);
      return;
    }
  }

  // 3) if they are still jumping, apply jump force
  if (state.isJumpHeld && state._currentjumpTimeMs > 0) {
    // apply jump force
    let jf = state.jumpForce;
    if (state._currentjumpTimeMs < dt) {
      jf *= state._currentjumpTimeMs / dt;
    }
    body.applyForce([0, jf, 0]);
    state._currentjumpTimeMs -= dt;
  } else {
    // the user let go of the jump key, so stop jumping
    state._currentjumpTimeMs = 0;
  }
};
