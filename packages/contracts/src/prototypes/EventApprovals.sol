// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { VoxelCoord, EventType } from "@tenet-contracts/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";

abstract contract EventApprovals is System {
  function preApproval(
    EventType eventType,
    address caller,
    bytes32 bodyTypeId,
    VoxelCoord memory coord
  ) internal virtual;

  function approveEvent(
    EventType eventType,
    address caller,
    bytes32 bodyTypeId,
    VoxelCoord memory coord
  ) internal virtual;

  function postApproval(
    EventType eventType,
    address caller,
    bytes32 bodyTypeId,
    VoxelCoord memory coord
  ) internal virtual;

  function approveMine(address caller, bytes32 bodyTypeId, VoxelCoord memory coord) public virtual {
    preApproval(EventType.Mine, caller, bodyTypeId, coord);
    approveEvent(EventType.Mine, caller, bodyTypeId, coord);
    postApproval(EventType.Mine, caller, bodyTypeId, coord);
  }

  function approveBuild(address caller, bytes32 bodyTypeId, VoxelCoord memory coord) public virtual {
    preApproval(EventType.Build, caller, bodyTypeId, coord);
    approveEvent(EventType.Build, caller, bodyTypeId, coord);
    postApproval(EventType.Build, caller, bodyTypeId, coord);
  }

  function approveActivate(address caller, bytes32 bodyTypeId, VoxelCoord memory coord) public virtual {
    preApproval(EventType.Activate, caller, bodyTypeId, coord);
    approveEvent(EventType.Activate, caller, bodyTypeId, coord);
    postApproval(EventType.Activate, caller, bodyTypeId, coord);
  }
}
