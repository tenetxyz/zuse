// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { ObjectType } from "@tenet-utils/src/Types.sol";

enum PokemonMove {
  None,
  Ember,
  FlameBurst,
  InfernoClash,
  SmokeScreen,
  FireShield,
  PyroBarrier,
  WaterGun,
  HydroPump,
  TidalCrash,
  Bubble,
  AquaRing,
  MistVeil,
  VineWhip,
  SolarBeam,
  ThornBurst,
  LeechSeed,
  Synthesis,
  VerdantGuard
}

struct MoveData {
  uint256 stamina;
  uint256 damage;
  uint256 protection;
  ObjectType moveType;
}

struct PlantConsumer {
  bytes32 entityId;
  uint256 consumedBlockNumber;
}
