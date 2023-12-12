// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { WorldObjectEventSystem as WorldObjectEventProtoSystem } from "@tenet-base-simulator/src/systems/WorldObjectEventSystem.sol";

abstract contract WorldObjectEventSystem is WorldObjectEventProtoSystem {
  function preRunObjectInteraction(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public override {}
}
