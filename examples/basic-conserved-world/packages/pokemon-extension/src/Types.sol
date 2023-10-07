// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { ObjectType } from "@tenet-utils/src/Types.sol";

enum PokemonMove {
  None,
  Ember,
  FlameBurst,
  SmokeScreen,
  FireShield,
  WaterGun,
  HydroPump,
  Bubble,
  AquaRing,
  VineWhip,
  SolarBeam,
  LeechSeed,
  Synthesis
}

struct MoveData {
  uint8 stamina;
  uint8 damage;
  uint8 protection;
  ObjectType moveType;
}
