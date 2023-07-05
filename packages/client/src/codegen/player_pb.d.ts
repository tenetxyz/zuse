import * as jspb from 'google-protobuf'



export class Coord3 extends jspb.Message {
  getX(): number;
  setX(value: number): Coord3;

  getY(): number;
  setY(value: number): Coord3;

  getZ(): number;
  setZ(value: number): Coord3;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): Coord3.AsObject;
  static toObject(includeInstance: boolean, msg: Coord3): Coord3.AsObject;
  static serializeBinaryToWriter(message: Coord3, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): Coord3;
  static deserializeBinaryFromReader(message: Coord3, reader: jspb.BinaryReader): Coord3;
}

export namespace Coord3 {
  export type AsObject = {
    x: number,
    y: number,
    z: number,
  }
}

export class Quaternion extends jspb.Message {
  getX(): number;
  setX(value: number): Quaternion;

  getY(): number;
  setY(value: number): Quaternion;

  getZ(): number;
  setZ(value: number): Quaternion;

  getW(): number;
  setW(value: number): Quaternion;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): Quaternion.AsObject;
  static toObject(includeInstance: boolean, msg: Quaternion): Quaternion.AsObject;
  static serializeBinaryToWriter(message: Quaternion, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): Quaternion;
  static deserializeBinaryFromReader(message: Quaternion, reader: jspb.BinaryReader): Quaternion;
}

export namespace Quaternion {
  export type AsObject = {
    x: number,
    y: number,
    z: number,
    w: number,
  }
}

export class Player extends jspb.Message {
  getId(): string;
  setId(value: string): Player;

  getPosition(): Coord3 | undefined;
  setPosition(value?: Coord3): Player;
  hasPosition(): boolean;
  clearPosition(): Player;

  getDirection(): Quaternion | undefined;
  setDirection(value?: Quaternion): Player;
  hasDirection(): boolean;
  clearDirection(): Player;

  getHealth(): number;
  setHealth(value: number): Player;

  getAttackCooldownTicksLeft(): number;
  setAttackCooldownTicksLeft(value: number): Player;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): Player.AsObject;
  static toObject(includeInstance: boolean, msg: Player): Player.AsObject;
  static serializeBinaryToWriter(message: Player, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): Player;
  static deserializeBinaryFromReader(message: Player, reader: jspb.BinaryReader): Player;
}

export namespace Player {
  export type AsObject = {
    id: string,
    position?: Coord3.AsObject,
    direction?: Quaternion.AsObject,
    health: number,
    attackCooldownTicksLeft: number,
  }
}

export class Attack extends jspb.Message {
  getAttackerId(): string;
  setAttackerId(value: string): Attack;

  getVictimId(): string;
  setVictimId(value: string): Attack;

  getDamage(): number;
  setDamage(value: number): Attack;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): Attack.AsObject;
  static toObject(includeInstance: boolean, msg: Attack): Attack.AsObject;
  static serializeBinaryToWriter(message: Attack, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): Attack;
  static deserializeBinaryFromReader(message: Attack, reader: jspb.BinaryReader): Attack;
}

export namespace Attack {
  export type AsObject = {
    attackerId: string,
    victimId: string,
    damage: number,
  }
}

