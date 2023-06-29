import vec3 from "gl-vec3";
import { RigidBody } from "noa-engine/dist/src/components/physics";

enum BodyState {
  onGround,
  inAir,
}

export interface IMovementState {
  heading: number; // radians
  running: boolean;
  isJumpHeld: boolean;

  // options
  maxSpeed: number;
  moveForce: number;
  responsiveness: number;
  runningFriction: number;
  standingFriction: number;

  // jumps
  airMoveMult: number;
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
    running: false,
    isJumpHeld: false,

    // options
    maxSpeed: 10,
    moveForce: 30,
    responsiveness: 15,
    runningFriction: 0,
    standingFriction: 2,

    // jumps
    airMoveMult: 0.5,
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

  exportMovementForcesToBody(state, body, dt, isOnGround ? BodyState.onGround : BodyState.inAir);

  // apply movement forces if entity is moving, otherwise just friction
  let m: any = tempvec;
  let push: any = tempvec2;
  if (state.running) {
    let speed: number = state.maxSpeed;
    // todo: add crouch/sprint modifiers if needed
    // if (state.sprint) speed *= state.sprintMoveMult
    // if (state.crouch) speed *= state.crouchMoveMult
    vec3.set(m, 0, 0, speed);

    // rotate move vector to entity's heading
    vec3.rotateY(m, m, zeroVec, state.heading);

    // push vector to achieve desired speed & dir
    // following code to adjust 2D velocity to desired amount is patterned on Quake:
    // https://github.com/id-Software/Quake-III-Arena/blob/master/code/game/bg_pmove.c#L275
    vec3.sub(push, m, body.velocity);
    push[1] = 0;
    let pushLen: number = vec3.len(push);
    vec3.normalize(push, push);

    if (pushLen > 0) {
      // pushing force vector
      let canPush: number = state.moveForce;
      if (!isOnGround) canPush *= state.airMoveMult;

      // apply final force
      let pushAmt: number = state.responsiveness * pushLen;
      if (canPush > pushAmt) canPush = pushAmt;

      vec3.scale(push, push, canPush);
      body.applyForce(push);
    }

    // different friction when not moving
    // idea from Sonic: http://info.sonicretro.org/SPG:Running
    body.friction = state.runningFriction;
  } else {
    body.friction = state.standingFriction;
  }
}

const doublePressedJump = (state: IMovementState) => {
  const currentTimeMs = new Date().getTime();
  return state.isJumpPressed && state._lastJumpPressTime + 500 > currentTimeMs; // checks that the last time we pressed jump was recent enough
};

const isFlying = (body: RigidBody) => {
  return body.gravityMultiplier === 0;
};

const exportMovementForcesToBody = (state: IMovementState, body: RigidBody, dt: number, bodyState: BodyState) => {
  let canJump = bodyState === BodyState.onGround || state._jumpCount < state.airJumps;

  if (doublePressedJump(state) && state.canFly) {
    // toggle flying
    if (isFlying(body)) {
      body.gravityMultiplier = 2;
    } else {
      body.gravityMultiplier = 0;
      body.velocity[1] = 0; // reset their velicity so they stop falling
    }
    return; // return. it's okay if we don't start going up until the next frame
  }

  // if the user is flying, or is still jumping, apply jump force
  if (state.isJumpHeld) {
    if (isFlying(body) || canJump) {
      var jf = state.jumpForce;
      if (state._currentJumpTime < dt) jf *= state._currentJumpTime / dt;
      body.applyForce([0, jf, 0]);
      state._currentJumpTime -= dt;
    }
  } else {
    // the user let go of the jump key, so stop jumping
    state._currentJumpTime = 0;
  }

  // if (state.isJumpHeld) {
  //   // continue previous jump
  //   return;
  //   // }
  //   // if (state.canFly) {
  //   //   if (body.gravityMultiplier === 0) {
  //   //     // you are flying and have jumped. you are now falling
  //   //     body.gravityMultiplier = 2;
  //   //   } else {
  //   //     // you have jumped while you are in the air. you are now flying
  //   //     body.gravityMultiplier = 0;
  //   //   }
  //   if (canjump) {
  //     // start new jump
  //     if (bodyState === BodyState.inAir) state._jumpCount++;
  //     state._currentJumpTime = state.jumpTime;
  //     body.applyImpulse([0, state.jumpImpulse, 0]);
  //     // clear downward velocity on airjump
  //     if (bodyState === BodyState.inAir && body.velocity[1] < 0) body.velocity[1] = 0;
  //   }
  // }

  if (state.isJumpPressed) {
    state._lastJumpPressTime = new Date().getTime();
  }
};
