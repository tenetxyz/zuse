// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, EventType } from "@tenet-utils/src/Types.sol";

import { SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { EventApprovalsSystem as EventApprovalsProtoSystem } from "@tenet-base-world/src/systems/EventApprovalsSystem.sol";

contract EventApprovalsSystem is EventApprovalsProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
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
  ) internal override {}

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
