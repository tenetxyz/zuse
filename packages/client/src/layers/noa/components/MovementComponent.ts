import vec3 from "gl-vec3";
import { RigidBody } from "noa-engine/dist/src/components/physics";

enum BodyState {
  onGround,
  inAir,
}

export interface IMovementState {
  heading: number; // radians
  running: boolean;
  onJump: boolean;

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

  canFly: boolean;
  isFlying: boolean;
  isCrouching: boolean;

  // internal state
  _jumpCount: number;
  _isJumping: boolean;
  _currjumptime: number;

  resting?: [number, number, number];
}

export function MovementState(): IMovementState {
  return {
    heading: 0,
    running: false,
    onJump: false,

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

    canFly: true,
    isFlying: false,
    isCrouching: false,

    // internal state
    _jumpCount: 0,
    _currjumptime: 0,
    _isJumping: false,
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
  // console.log(isOnGround);
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

const exportMovementForcesToBody = (state: IMovementState, body: RigidBody, dt: number, bodyState: BodyState) => {
  let canjump = bodyState === BodyState.onGround || state._jumpCount < state.airJumps;

  if (state.onJump) {
    if (state._isJumping) {
      // continue previous jump
      if (state._currjumptime > 0) {
        var jf = state.jumpForce;
        if (state._currjumptime < dt) jf *= state._currjumptime / dt;
        body.applyForce([0, jf, 0]);
        state._currjumptime -= dt;
      }
    } else if (canjump) {
      // start new jump
      state._isJumping = true;
      if (bodyState === BodyState.inAir) state._jumpCount++;
      state._currjumptime = state.jumpTime;
      body.applyImpulse([0, state.jumpImpulse, 0]);
      // clear downward velocity on airjump
      if (bodyState === BodyState.inAir && body.velocity[1] < 0) body.velocity[1] = 0;
    }
  } else {
    state._isJumping = false;
  }

  // if (state.onJump) {
  //   if (state.canFly) {
  //     state.isFlying = true;
  //     body.applyForce([0, state.jumpForce, 0]);
  //     body.velocity[1] = 0;
  //   } else {
  //     // the user is trying to do an air jump
  //     if (state._jumpCount < state.airJumps) {
  //       state._jumpCount++;
  //       state._currjumptime = state.jumpTime;
  //       body.applyImpulse([0, state.jumpImpulse, 0]);
  //     }
  //   }
  // }
};
