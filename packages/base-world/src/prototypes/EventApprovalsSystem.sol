// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { EventType } from "@tenet-base-world/src/Types.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";

abstract contract EventApprovalsSystem is System {
  function preApproval(
    EventType eventType,
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord
  ) internal virtual;

  function approveEvent(
    EventType eventType,
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord
  ) internal virtual;

  function postApproval(
    EventType eventType,
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord
  ) internal virtual;

  function approveMine(address caller, bytes32 voxelTypeId, VoxelCoord memory coord) public virtual {
    preApproval(EventType.Mine, caller, voxelTypeId, coord);
    approveEvent(EventType.Mine, caller, voxelTypeId, coord);
    postApproval(EventType.Mine, caller, voxelTypeId, coord);
  }

  function approveBuild(address caller, bytes32 voxelTypeId, VoxelCoord memory coord) public virtual {
    preApproval(EventType.Build, caller, voxelTypeId, coord);
    approveEvent(EventType.Build, caller, voxelTypeId, coord);
    postApproval(EventType.Build, caller, voxelTypeId, coord);
  }

  function approveActivate(address caller, bytes32 voxelTypeId, VoxelCoord memory coord) public virtual {
    preApproval(EventType.Activate, caller, voxelTypeId, coord);
    approveEvent(EventType.Activate, caller, voxelTypeId, coord);
    postApproval(EventType.Activate, caller, voxelTypeId, coord);
  }
}
