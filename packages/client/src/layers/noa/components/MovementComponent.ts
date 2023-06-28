import vec3 from "gl-vec3";

export interface IMovementState {
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

  canFly: boolean;
  isFlying: boolean;
  isCrouching: boolean;

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

    canFly: true,
    isFlying: false,
    isCrouching: false,

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
        if (phys) applyMovementPhysics(dt, state, phys);
      }
    },
  };
}

const tempvec = vec3.create();
const tempvec2 = vec3.create();
const zeroVec = vec3.create();

// function applyMovementPhysics(dt: number, state: IMovementState, body: IPhysicsBody) {
//   // move implementation originally written as external module
//   // see https://github.com/fenomas/voxel-fps-controller
//   // for original code
//   if (body.hasOwnProperty("body")) {
//     body = body.body;
//   }
//   let onGround = body.velocity[1] === 0;
//   if (onGround) {
//     state._isJumping = false;
//     state._jumpCount = 0;
//   }

//   let canjump = onGround || state._jumpCount < state.airJumps;

//   // if (state.isFlying) {
//   //   body.velocity[1] = 0; // so the user doesn't fall
//   //   if (state.jumping) {
//   //     body.applyForce([0, state.moveForce, 0]); // move upward
//   //   } else if (state.isCrouching) {
//   //     body.applyForce([0, -state.moveForce, 0]); // move downward
//   //   }
//   // } else {
//   // process jump input
//   if (state.jumping) {
//     if (state._isJumping) {
//       // continue previous jump
//       if (state._currjumptime > 0) {
//         let jumpForce: number = state.jumpForce;
//         if (state._currjumptime < dt) jumpForce *= state._currjumptime / dt;
//         body.applyForce([0, jumpForce, 0]);
//         state._currjumptime -= dt;
//       }
//     } else if (canjump) {
//       // start new jump
//       state._isJumping = true;
//       if (!onGround) state._jumpCount++;
//       state._currjumptime = state.jumpTime;
//       body.applyImpulse([0, state.jumpImpulse, 0]);
//       // clear downward velocity on airjump
//       if (!onGround && body.velocity[1] < 0) body.velocity[1] = 0;
//     }
//   } else {
//     state._isJumping = false;
//   }
//   // }

//   // exportMovementForcesToBody(state, body, dt, onGround);

//   // apply movement forces if entity is moving, otherwise just friction
//   let m: any = tempvec;
//   let push: any = tempvec2;
//   if (state.running) {
//     let speed: number = state.maxSpeed;
//     // todo: add crouch/sprint modifiers if needed
//     // if (state.sprint) speed *= state.sprintMoveMult
//     // if (state.crouch) speed *= state.crouchMoveMult
//     vec3.set(m, 0, 0, speed);

//     // rotate move vector to entity's heading
//     vec3.rotateY(m, m, zeroVec, state.heading);

//     // push vector to achieve desired speed & dir
//     // following code to adjust 2D velocity to desired amount is patterned on Quake:
//     // https://github.com/id-Software/Quake-III-Arena/blob/master/code/game/bg_pmove.c#L275
//     vec3.sub(push, m, body.velocity);
//     push[1] = 0;
//     let pushLen: number = vec3.len(push);
//     vec3.normalize(push, push);

//     if (pushLen > 0) {
//       // pushing force vector
//       let canPush: number = state.moveForce;
//       if (!onGround) canPush *= state.airMoveMult;

//       // apply final force
//       let pushAmt: number = state.responsiveness * pushLen;
//       if (canPush > pushAmt) canPush = pushAmt;

//       vec3.scale(push, push, canPush);
//       body.applyForce(push);
//     }

//     // different friction when not moving
//     // idea from Sonic: http://info.sonicretro.org/SPG:Running
//     body.friction = state.runningFriction;
//   } else {
//     body.friction = state.standingFriction;
//   }
// }

// const exportMovementForcesToBody = (state: IMovementState, body: IPhysicsBody, dt: number, onGround: boolean) => {
//   let canjump = onGround || state._jumpCount < state.airJumps;

//   if (state.isFlying) {
//     body.velocity[1] = 0; // so the user doesn't fall
//     if (state.jumping) {
//       body.applyForce([0, state.moveForce, 0]); // move upward
//     } else if (state.isCrouching) {
//       body.applyForce([0, -state.moveForce, 0]); // move downward
//     }
//   } else {
//     // process jump input
//     if (state.jumping) {
//       if (state._isJumping) {
//         // continue previous jump
//         if (state._currjumptime > 0) {
//           let jumpForce: number = state.jumpForce;
//           if (state._currjumptime < dt) jumpForce *= state._currjumptime / dt;
//           body.applyForce([0, jumpForce, 0]);
//           state._currjumptime -= dt;
//         }
//       } else if (canjump) {
//         // start new jump
//         state._isJumping = true;
//         if (!onGround) state._jumpCount++;
//         state._currjumptime = state.jumpTime;
//         body.applyImpulse([0, state.jumpImpulse, 0]);
//         // clear downward velocity on airjump
//         if (!onGround && body.velocity[1] < 0) body.velocity[1] = 0;
//       }
//     } else {
//       state._isJumping = false;
//     }
//   }
// };
// const exportMovementForcesToBody = (state: IMovementState, body: IPhysicsBody, dt: number, onGround: boolean) => {
//   let canjump = onGround || (state._jumpCount < state.airJumps && state.canFly);

//   if (state.isFlying) {
//     body.velocity[1] = 0;
//     body.applyForce([0, state.jumping ? state.moveForce : -state.moveForce * Number(state.isCrouching), 0]);
//   } else {
//     if (state.jumping && canjump) {
//       state._isJumping = true;
//       state._currjumptime = onGround ? state.jumpTime : state._currjumptime - dt;
//       body.velocity[1] = onGround ? 0 : body.velocity[1];
//       state._jumpCount += Number(!onGround);
//       body[onGround ? "applyImpulse" : "applyForce"]([0, onGround ? state.jumpImpulse : state.jumpForce, 0]);
//     } else {
//       state._isJumping = false;
//     }
//   }
// };

function applyMovementPhysics(dt, state, body) {
  // move implementation originally written as external module
  //   see https://github.com/fenomas/voxel-fps-controller
  //   for original code
  if (body.hasOwnProperty("body")) {
    body = body.body;
  }

  // jumping
  var onGround = body.atRestY() < 0;
  var canjump = onGround || state._jumpCount < state.airJumps;
  if (onGround) {
    state._isJumping = false;
    state._jumpCount = 0;
  }

  // process jump input
  if (state.jumping) {
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
  var m = tempvec;
  var push = tempvec2;
  if (state.running) {
    var speed = state.maxSpeed;
    // todo: add crouch/sprint modifiers if needed
    // if (state.sprint) speed *= state.sprintMoveMult
    // if (state.crouch) speed *= state.crouchMoveMult
    vec3.set(m, 0, 0, speed);

    // rotate move vector to entity's heading
    vec3.rotateY(m, m, zeroVec, state.heading);

    // push vector to achieve desired speed & dir
    // following code to adjust 2D velocity to desired amount is patterned on Quake:
    // https://github.com/id-Software/Quake-III-Arena/blob/master/code/game/bg_pmove.c#L275
    vec3.subtract(push, m, body.velocity);
    push[1] = 0;
    var pushLen = vec3.length(push);
    vec3.normalize(push, push);

    if (pushLen > 0) {
      // pushing force vector
      var canPush = state.moveForce;
      if (!onGround) canPush *= state.airMoveMult;

      // apply final force
      var pushAmt = state.responsiveness * pushLen;
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
