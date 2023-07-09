// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { SpawnData } from "@tenet-contracts/src/codegen/Tables.sol";

// The classifier system that is called when a player submits a spawn for classifiaction
abstract contract Classifier is System {
  // Called by the world to classify a spawn
  function classify(
    address worldAddress,
    SpawnData memory spawn,
    bytes32 spawnId,
    bytes32[] memory input
  ) public virtual;
}
