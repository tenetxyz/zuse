// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { EventApprovals } from "../prototypes/EventApprovals.sol";
import { VoxelCoord, EventType } from "@tenet-base-world/src/Types.sol";

contract ApprovalSystem is EventApprovals {
  function preApproval(
    EventType eventType,
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord
  ) internal override {}

  function postApproval(
    EventType eventType,
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord
  ) internal override {}

  function approveEvent(
    EventType eventType,
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord
  ) internal override {}

  function approveMine(address caller, bytes32 voxelTypeId, VoxelCoord memory coord) public override {
    super.approveMine(caller, voxelTypeId, coord);
  }

  function approveBuild(address caller, bytes32 voxelTypeId, VoxelCoord memory coord) public override {
    super.approveBuild(caller, voxelTypeId, coord);
  }

  function approveActivate(address caller, bytes32 voxelTypeId, VoxelCoord memory coord) public override {
    super.approveActivate(caller, voxelTypeId, coord);
  }
}
