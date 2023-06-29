import vec3 from "gl-vec3";
import { RigidBody } from "noa-engine/dist/src/components/physics";

enum BodyState {
  onGround,
  inAir,
}

export interface IMovementState {
  heading: number; // radians
  isRunning: boolean;
  isJumpHeld: boolean;

  // options
  runningSpeed: number;
  flyingSpeed: number;
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
    isRunning: false,
    isJumpHeld: false,

    // options
    runningSpeed: 10,
    flyingSpeed: 100,
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
    push[1] = 0;
    let pushLen: number = vec3.len(push);
    vec3.normalize(push, push);

    if (pushLen > 0) {
      // pushing force vector
      let canPush: number = state.moveForce;

      // scale the pushing force vector based on state
      if (!isOnGround) {
        canPush *= state.airMoveMult;
      }

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

const toggleFlying = (body: RigidBody) => {
  if (isFlying(body)) {
    // they are falling now
    body.gravityMultiplier = 2;
    body.airDrag = 0.1;
    return; // we are now falling, so no need to jump
  } else {
    // they are flying now
    body.gravityMultiplier = 0;
    body.velocity[1] = 10; // reset their velocity so they stop falling
    body.airDrag = 0;
    return; // return. It's okay if we don't start going up until the next frame
  }
};

const exportMovementForcesToBody = (state: IMovementState, body: RigidBody, dt: number, bodyState: BodyState) => {
  const canJump = bodyState === BodyState.onGround || state._jumpCount < state.airJumps;

  if (isFlying(body)) {
    if (state.isCrouching) {
      // fly down
      // body.applyForce([0, -40, 0]);
      body.velocity[1] = -10;
      return;
    } else if (state.isJumpHeld) {
      // fly up
      body.velocity[1] = 10;
      return;
    } else {
      body.velocity[1] = 0;
      if (!state.isRunning) {
        // we are flying and not pressing wasd. So stop moving
        body.velocity[0] = 0;
        body.velocity[2] = 0;
      }
    }
  }

  // 1) toggle flying if they can fly
  if (doublePressedJump(state) && state.canFly) {
    toggleFlying(body);
  }

  // 2) if they just pressed jump, start a jump
  // Note: isJumpPressed is only true on the frame the jump key is pressed
  if (state.isJumpPressed && (canJump || isFlying(body))) {
    // start new jump
    state._jumpCount++;
    state._currentJumpTime = state.jumpTime;
    body.applyImpulse([0, state.jumpImpulse, 0]);
    state._lastJumpPressTime = new Date().getTime();
    return;
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
