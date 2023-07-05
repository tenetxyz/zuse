// package: Shard
// file: proto/player.proto

import * as jspb from "google-protobuf";

export class Coord3 extends jspb.Message {
  getX(): number;
  setX(value: number): void;

  getY(): number;
  setY(value: number): void;

  getZ(): number;
  setZ(value: number): void;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): Coord3.AsObject;
  static toObject(includeInstance: boolean, msg: Coord3): Coord3.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
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
  setX(value: number): void;

  getY(): number;
  setY(value: number): void;

  getZ(): number;
  setZ(value: number): void;

  getW(): number;
  setW(value: number): void;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): Quaternion.AsObject;
  static toObject(includeInstance: boolean, msg: Quaternion): Quaternion.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
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
  setId(value: string): void;

  hasPosition(): boolean;
  clearPosition(): void;
  getPosition(): Coord3 | undefined;
  setPosition(value?: Coord3): void;

  hasDirection(): boolean;
  clearDirection(): void;
  getDirection(): Quaternion | undefined;
  setDirection(value?: Quaternion): void;

  getHealth(): number;
  setHealth(value: number): void;

  getAttackCooldownTicksLeft(): number;
  setAttackCooldownTicksLeft(value: number): void;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): Player.AsObject;
  static toObject(includeInstance: boolean, msg: Player): Player.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
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
  setAttackerId(value: string): void;

  getVictimId(): string;
  setVictimId(value: string): void;

  getDamage(): number;
  setDamage(value: number): void;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): Attack.AsObject;
  static toObject(includeInstance: boolean, msg: Attack): Attack.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
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

