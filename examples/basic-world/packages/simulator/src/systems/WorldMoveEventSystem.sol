// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, EventType } from "@tenet-utils/src/Types.sol";
import { WorldMoveEventSystem as WorldMoveEventProtoSystem } from "@tenet-base-simulator/src/systems/WorldMoveEventSystem.sol";

contract WorldMoveEventSystem is WorldMoveEventProtoSystem {
  function preMoveEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord
  ) public override {}

  function onMoveEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    bytes32 objectEntityId
  ) public override returns (bytes32) {
    return objectEntityId;
  }

  function postMoveEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    bytes32 objectEntityId
  ) public override {}
}
