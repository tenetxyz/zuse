// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

abstract contract WorldObjectEventSystem is System {
  function preRunObjectInteraction(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public virtual;

  // Note: add onObjectInteraction and postObjectInteraction as we need them
}
