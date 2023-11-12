// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { EventType } from "@tenet-base-world/src/Types.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";

abstract contract EventApprovalsSystem is System {
  function preApproval(
    EventType eventType,
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual;

  function approveEvent(
    EventType eventType,
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual;

  function postApproval(
    EventType eventType,
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual;

  function approveMine(
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) public virtual {
    preApproval(EventType.Mine, caller, actingObjectEntityId, objectTypeId, coord, eventData);
    approveEvent(EventType.Mine, caller, actingObjectEntityId, objectTypeId, coord, eventData);
    postApproval(EventType.Mine, caller, actingObjectEntityId, objectTypeId, coord, eventData);
  }

  function approveBuild(
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) public virtual {
    preApproval(EventType.Build, caller, actingObjectEntityId, objectTypeId, coord, eventData);
    approveEvent(EventType.Build, caller, actingObjectEntityId, objectTypeId, coord, eventData);
    postApproval(EventType.Build, caller, actingObjectEntityId, objectTypeId, coord, eventData);
  }

  function approveActivate(
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) public virtual {
    preApproval(EventType.Activate, caller, actingObjectEntityId, objectTypeId, coord, eventData);
    approveEvent(EventType.Activate, caller, actingObjectEntityId, objectTypeId, coord, eventData);
    postApproval(EventType.Activate, caller, actingObjectEntityId, objectTypeId, coord, eventData);
  }

  function approveMove(
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) public virtual {
    preApproval(EventType.Move, caller, actingObjectEntityId, objectTypeId, coord, eventData);
    approveEvent(EventType.Move, caller, actingObjectEntityId, objectTypeId, coord, eventData);
    postApproval(EventType.Move, caller, actingObjectEntityId, objectTypeId, coord, eventData);
  }
}
