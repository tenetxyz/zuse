import vec3 from "gl-vec3";
import { RigidBody } from "noa-engine/dist/src/components/physics";
import { GRAVITY_MULTIPLIER } from "../constants";

export interface IMovementState {
  heading: number; // radians
  isRunning: boolean;
  isJumpHeld: boolean;
  isPlayerSlowedToAStop: boolean;

  // options
  runningSpeed: number;
  flyingSpeed: number; // horizontal flying speed
  ascendAndDescendSpeed: number; // vertical flying speed
  jumpingInAirSpeed: number;
  runningFriction: number;
  standingFriction: number;

  // jumps
  jumpImpulse: number;
  jumpForce: number;
  jumpTimeMs: number;
  maxJumps: number;
  isJumpPressed: boolean;
  doublePressJumpTimeWindowMs: number; // if the user presses jump twice within this time window, then they will start flying/stop flying

  canFly: boolean;
  isCrouching: boolean;

  // internal state
  _jumpCount: number;
  _timeRemainingInJumpMs: number;
  _lastJumpPressTimeMs: number;

  __id?: string;
}

export function MovementState(): IMovementState {
  return {
    heading: 0,
    isRunning: false,
    isJumpHeld: false,
    isPlayerSlowedToAStop: false,

    // options
    runningSpeed: 7,
    flyingSpeed: 12,
    ascendAndDescendSpeed: 15,
    jumpingInAirSpeed: 10,
    runningFriction: 0,
    standingFriction: 2,

    // jumps
    jumpImpulse: 10, // in physics, impulse is force * delta t
    jumpForce: 12,
    jumpTimeMs: 500, // This determines how long the jump force should be applied
    maxJumps: 2,
    isJumpPressed: false,
    doublePressJumpTimeWindowMs: 400,

    canFly: true,
    isCrouching: false,

    // internal state
    _jumpCount: 0,
    _timeRemainingInJumpMs: 0,
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
        const positionData = ents.getPositionData(state.__id);
        console.log(positionData.position);
        const phys = ents.getPhysics(state.__id);
        if (phys) applyMovementPhysics(dt, state, phys.body);
      }
    },
  };
}

// create the vectors here so we don't need to create them on each frame
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
  if (state.isPlayerSlowedToAStop) {
    slowToAStop(body);
    return;
  }

  applyVerticalForces(state, body, dt, isOnGround);

  // apply movement forces if entity is moving, otherwise just friction
  if (state.isRunning) {
    applyHorizontalForces(state, body, isOnGround);

    // different friction when not moving. idea from Sonic: http://info.sonicretro.org/SPG:Running
    body.friction = state.runningFriction;
  } else {
    body.friction = state.standingFriction;
    if (isFlying(body)) {
      slowToAStop(body);
    }
  }
}

const slowToAStop = (body: ExtendedRigidBody) => {
  // only slow the horizontal velocity since it'd be weird if the player was in the air and can't fall
  body.velocity[0] *= 0.5;
  body.velocity[2] *= 0.5;
};

const applyHorizontalForces = (state: IMovementState, body: ExtendedRigidBody, isOnGround: boolean) => {
  let speed = getDesiredPlayerSpeed(state, body, isOnGround);
  let moveVec: any = tempvec;
  let pushVector: any = tempvec2; // this vector is what will push the body to the desired velocity
  vec3.set(moveVec, 0, 0, speed);
  vec3.rotateY(moveVec, moveVec, zeroVec, state.heading); // rotate move vector to entity's heading

  // push vector to achieve desired speed & dir
  // following code to adjust 2D velocity to desired amount is patterned on Quake:
  // https://github.com/id-Software/Quake-III-Arena/blob/master/code/game/bg_pmove.c#L275
  vec3.sub(pushVector, moveVec, body.velocity);
  pushVector[1] = 0; // the user's WASD movement shouldn't affect their Y velocity

  const bodyDir = body.velocity;
  const directionVec = vec3.dot(pushVector, bodyDir);

  const userWantsToMoveInOppositeDir = directionVec < 0 && vec3.len(pushVector) > vec3.len(body.velocity);
  if (userWantsToMoveInOppositeDir && isOnGround) {
    // to make the player feel more responsive on the ground, we'll apply a larger force if they are switching directions
    vec3.scale(pushVector, pushVector, speed * 1.5);
    body.applyForce(pushVector);
    return;
  }

  if (!isOnGround) {
    speed *= 0.1; // don't let them swap directions easily in the air
  }

  vec3.scale(pushVector, pushVector, speed);
  body.applyForce(pushVector);
};

const getDesiredPlayerSpeed = (state: IMovementState, body: ExtendedRigidBody, isOnGround: boolean): number => {
  if (isFlying(body)) {
    return state.flyingSpeed;
  } else if (isOnGround) {
    return state.runningSpeed;
  } else {
    return state.jumpingInAirSpeed;
  }
};

const doublePressedJump = (state: IMovementState) => {
  const currentTimeMs = new Date().getTime();
  return state.isJumpPressed && state._lastJumpPressTimeMs + state.doublePressJumpTimeWindowMs > currentTimeMs; // checks that the last time we pressed jump was recent enough
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
const accelerateVerticalSpeed = (targetSpeed: number, body: RigidBody) => {
  // if the body isn't travelling in the right direction, then we want to accelerate it more
  if (body.velocity[1] * targetSpeed < 0) {
    return targetSpeed * 6;
  }
  if (Math.abs(body.velocity[1]) < 0.5 * Math.abs(targetSpeed)) {
    return targetSpeed * 2; // give it more acceleration if it's going slow
  }
  return targetSpeed;
};

const applyVerticalForces = (state: IMovementState, body: ExtendedRigidBody, dt: number, isOnGround: boolean) => {
  const canJump = isOnGround || state._jumpCount < state.maxJumps;

  // 1) apply forces to someone that's flying
  if (isFlying(body)) {
    handleVerticleForces(state, body);
  }

  // 2) toggle flying if they can fly
  if (doublePressedJump(state) && state.canFly) {
    toggleFlying(body);
    state._lastJumpPressTimeMs = 0; // reset the last jump press time so we don't double jump when we press jump again
    return;
  }

  // 3) if they just pressed jump, start a jump
  // Note: isJumpPressed is only true on the frame the jump key is pressed
  if (state.isJumpPressed) {
    initiateJump(state, body, canJump);
    return;
  }

  // 4) if they are still jumping, apply jump force
  const isStillJumping = state.isJumpHeld && state._timeRemainingInJumpMs > 0;
  if (isStillJumping) {
    applyJumpForce(state, body, dt);
  } else {
    // the user let go of the jump key, so stop jumping
    state._timeRemainingInJumpMs = 0;
  }
};

const handleVerticleForces = (state: IMovementState, body: ExtendedRigidBody) => {
  if (state.isCrouching) {
    // fly down
    body.applyForce([0, accelerateVerticalSpeed(-state.ascendAndDescendSpeed, body), 0]);
    return;
  } else if (state.isJumpHeld) {
    // fly up
    body.applyForce([0, accelerateVerticalSpeed(state.ascendAndDescendSpeed, body), 0]);
  } else {
    // the user isn't going up or down, so try to slow it down
    body.velocity[1] *= 0.5; // multiply velocity by 0.5 to gradually slow down
  }
};

const initiateJump = (state: IMovementState, body: ExtendedRigidBody, canJump: boolean) => {
  state._lastJumpPressTimeMs = new Date().getTime();
  if (isFlying(body)) {
    body.applyForce([0, 10, 0]);
  } else if (canJump) {
    // start new jump
    state._jumpCount++;
    state._timeRemainingInJumpMs = state.jumpTimeMs;
    body.applyImpulse([0, state.jumpImpulse, 0]);
  }
};

const applyJumpForce = (state: IMovementState, body: ExtendedRigidBody, dt: number) => {
  let jf = state.jumpForce;
  if (state._timeRemainingInJumpMs < dt) {
    jf *= state._timeRemainingInJumpMs / dt;
  }
  body.applyForce([0, jf, 0]);
  state._timeRemainingInJumpMs -= dt;
};
