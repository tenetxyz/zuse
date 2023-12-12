// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, EventType } from "@tenet-utils/src/Types.sol";
import { WorldMineEventSystem as WorldMineEventProtoSystem } from "@tenet-base-simulator/src/systems/WorldMineEventSystem.sol";

contract WorldMineEventSystem is WorldMineEventProtoSystem {
  function preMineEvent(bytes32 actingObjectEntityId, bytes32 objectTypeId, VoxelCoord memory coord) public override {}

  function onMineEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) public override {}

  function postMineEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) public override {}
}
