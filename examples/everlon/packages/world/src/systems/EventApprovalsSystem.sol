// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, EventType } from "@tenet-utils/src/Types.sol";

import { SIMULATOR_ADDRESS, NUM_MAX_AGENT_ACTION_RADIUS } from "@tenet-world/src/Constants.sol";
import { EventApprovalsSystem as EventApprovalsProtoSystem } from "@tenet-base-world/src/systems/EventApprovalsSystem.sol";
import { MoveEventData } from "@tenet-world/src/Types.sol";

contract EventApprovalsSystem is EventApprovalsProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function getMaxAgentActionRadius() internal pure override returns (uint256) {
    return NUM_MAX_AGENT_ACTION_RADIUS;
  }

  function getOldCoord(bytes memory eventData) internal pure override returns (VoxelCoord memory) {
    MoveEventData memory moveEventData = abi.decode(eventData, (MoveEventData));
    return moveEventData.oldCoord;
  }

  function preApproval(
    EventType eventType,
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal override {
    return super.preApproval(eventType, caller, actingObjectEntityId, objectTypeId, coord, eventData);
  }

  function approveEvent(
    EventType eventType,
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal override {
    bool isWorldCaller = caller == _world(); // any root system can call this
    bool isSimCaller = caller == getSimulatorAddress();
    if (!isWorldCaller && !isSimCaller) {
      if (eventType == EventType.Build || eventType == EventType.Mine) {
        // revert("EventApprovalsSystem: Only the world or simulator can call build or mine");
      }
    }
  }

  function postApproval(
    EventType eventType,
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal override {}

  function approveMine(
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) public override {
    return super.approveMine(caller, actingObjectEntityId, objectTypeId, coord, eventData);
  }

  function approveBuild(
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) public override {
    return super.approveBuild(caller, actingObjectEntityId, objectTypeId, coord, eventData);
  }

  function approveActivate(
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) public override {
    return super.approveActivate(caller, actingObjectEntityId, objectTypeId, coord, eventData);
  }

  function approveMove(
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) public override {
    return super.approveMove(caller, actingObjectEntityId, objectTypeId, coord, eventData);
  }
}
