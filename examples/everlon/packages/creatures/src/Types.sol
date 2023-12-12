// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { ElementType } from "@tenet-utils/src/Types.sol";

enum CreatureMove {
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

struct CreatureMoveData {
  uint256 stamina;
  uint256 damage;
  uint256 protection;
  ElementType moveType;
}
