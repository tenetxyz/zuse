import vec3 from "gl-vec3";

interface IMovementState {
  heading: number; // radians
  running: boolean;
  jumping: boolean;

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

  // internal state
  _jumpCount: number;
  _currjumptime: number;
  _isJumping: boolean;
}

export function MovementState(): IMovementState {
  return {
    heading: 0,
    running: false,
    jumping: false,

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

    // internal state
    _jumpCount: 0,
    _currjumptime: 0,
    _isJumping: false,
  };
}

interface IPhysicsBody {
  atRestY(): number;
  applyForce(force: number[]): void;
  applyImpulse(impulse: number[]): void;
  velocity: number[];
  friction: number;
}

interface IEntity {
  getPhysics(id: string): IPhysicsBody | undefined;
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

export const MOVEMENT_COMPONENT_NAME = "tenet-movement";

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
        if (phys) applyMovementPhysics(dt, state, phys);
      }
    },
  };
}

const tempvec = vec3.create();
const tempvec2 = vec3.create();
const zeroVec = vec3.create();

function applyMovementPhysics(dt: number, state: IMovementState, body: IPhysicsBody) {
  // move implementation originally written as external module
  // see https://github.com/fenomas/voxel-fps-controller
  // for original code

  // jumping
  let onGround = body.atRestY() < 0;
  let canjump = onGround || state._jumpCount < state.airJumps;
  if (onGround) {
    state._isJumping = false;
    state._jumpCount = 0;
  }

  // process jump input
  if (state.jumping) {
    if (state._isJumping) {
      // continue previous jump
      if (state._currjumptime > 0) {
        let jf: number = state.jumpForce;
        if (state._currjumptime < dt) jf *= state._currjumptime / dt;
        body.applyForce([0, jf, 0]);
        state._currjumptime -= dt;
      }
    } else if (canjump) {
      // start new jump
      state._isJumping = true;
      if (!onGround) state._jumpCount++;
      state._currjumptime = state.jumpTime;
      body.applyImpulse([0, state.jumpImpulse, 0]);
      // clear downward velocity on airjump
      if (!onGround && body.velocity[1] < 0) body.velocity[1] = 0;
    }
  } else {
    state._isJumping = false;
  }

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
      if (!onGround) canPush *= state.airMoveMult;

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
