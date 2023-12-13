// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Creature } from "@tenet-creatures/src/codegen/tables/Creature.sol";
import { Thermo } from "@tenet-creatures/src/codegen/tables/Thermo.sol";

function entityIsCreature(address worldAddress, bytes32 objectEntityId) view returns (bool) {
  return Creature.getHasValue(worldAddress, objectEntityId);
}

function entityIsThermo(address worldAddress, bytes32 objectEntityId) view returns (bool) {
  return Thermo.getHasValue(worldAddress, objectEntityId);
}
