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
  jumpingInAirSpeed: number;
  moveForce: number;
  runningFriction: number;
  standingFriction: number;

  // jumps
  jumpImpulse: number;
  jumpForce: number;
  jumpTime: number; // ms
  airJumps: number;
  isJumpPressed: boolean;

  canFly: boolean;
  isCrouching: boolean;

  // internal state
  _jumpCount: number;
  _currentJumpTime: number;
  _lastJumpPressTime: number;

  resting?: [number, number, number];
}

export function MovementState(): IMovementState {
  return {
    heading: 0,
    isRunning: false,
    isJumpHeld: false,

    // options
    runningSpeed: 10,
    flyingSpeed: 20,
    jumpingInAirSpeed: 15,
    moveForce: 10,
    runningFriction: 0,
    standingFriction: 2,

    // jumps
    jumpImpulse: 10,
    jumpForce: 12,
    jumpTime: 500, // ms
    airJumps: 1,
    isJumpPressed: false,

    canFly: true,
    isCrouching: false,

    // internal state
    _jumpCount: 0,
    _currentJumpTime: 0,
    _lastJumpPressTime: 0,
  };
}

interface IEntity {
  getPhysics(id: string): RigidBody | undefined;
}

interface IEngine {
  entities: IEntity;
}

interface IMovement {
  name: string;
  order: number;
  state: IMovementState;
  onAdd: null;
  onRemove: null;
  system(dt: number, states: IMovementState[]): void;
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

function applyMovementPhysics(dt: number, state: IMovementState, body: RigidBody) {
  // move implementation originally written as external module
  // see https://github.com/fenomas/voxel-fps-controller
  // for original code

  // if vecloicy is 0 and isresting is ttrue, then we know it's on ground
  // if velocity is nonzero it's not on ground
  let isOnGround = body.atRestY() < 0;
  if (isOnGround) {
    state._jumpCount = 0;
  }

  exportMovementForcesToBody(state, body, dt, isOnGround);
  if (state.isJumpPressed) {
    state._lastJumpPressTime = new Date().getTime();
  }

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

const accelerateBodyToVelocityAtSpeed = (normalVec: number[], body: RigidBody, speed: number) => {
  // const diff = Math.abs(speed - normalVec.length);
  const diff = speed - normalVec.length;
  // the math equation basically says:
  // the further you are from the flying speed (the diff variable), the larger our push should be
  vec3.scale(normalVec, normalVec, speed * (1 + (diff / speed) * 1.5));
  body.applyForce(normalVec);
};

const doublePressedJump = (state: IMovementState) => {
  const currentTimeMs = new Date().getTime();
  return state.isJumpPressed && state._lastJumpPressTime + 600 > currentTimeMs; // checks that the last time we pressed jump was recent enough
};

const isFlying = (body: RigidBody) => {
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

const accelerateToSpeed2 = (targetSpeed: number, body: RigidBody, earlyAccelerationMultiplier = 2) => {
  const diff = targetSpeed - vec3.len(body.velocity);
  return targetSpeed + (targetSpeed - vec3.len(body.velocity) * earlyAccelerationMultiplier);
};

const exportMovementForcesToBody = (state: IMovementState, body: RigidBody, dt: number, isOnGround: boolean) => {
  const canJump = isOnGround || state._jumpCount < state.airJumps;

  if (isFlying(body)) {
    if (state.isCrouching) {
      // body.velocity[1] = -10;
      // accelerateBodyToVelocityAtSpeed([0, -1, 0], body, 5, 30);
      body.applyForce([0, -1 * accelerateToSpeed2(15, body), 0]);
      return;
    } else if (state.isJumpHeld) {
      body.applyForce([0, 1 * accelerateToSpeed2(15, body), 0]);
      // fly up
      // body.velocity[1] = 10;
      // accelerateBodyToVelocityAtSpeed([0, 1, 0], body, 5, 30);
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
    return;
  }

  // 2) if they just pressed jump, start a jump
  // Note: isJumpPressed is only true on the frame the jump key is pressed
  if (state.isJumpPressed) {
    if (isFlying(body)) {
      // just give them upwards velocity. do NOT give them a massive impulse like below
      // body.velocity[1] = 10;
      body.applyForce([0, 10, 0]);
      return;
    } else if (canJump) {
      // start new jump
      state._jumpCount++;
      state._currentJumpTime = state.jumpTime;
      body.applyImpulse([0, state.jumpImpulse, 0]);
      return;
    }
  }

  // 3) if they are still jumping, apply jump force
  if (state.isJumpHeld && state._currentJumpTime > 0) {
    // apply jump force
    let jf = state.jumpForce;
    if (state._currentJumpTime < dt) {
      jf *= state._currentJumpTime / dt;
    }
    body.applyForce([0, jf, 0]);
    state._currentJumpTime -= dt;
  } else {
    // the user let go of the jump key, so stop jumping
    state._currentJumpTime = 0;
  }
};
