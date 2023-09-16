// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { EventApprovalsSystem } from "@tenet-base-world/src/prototypes/EventApprovalsSystem.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { EventType } from "@tenet-base-world/src/Types.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

contract ApprovalSystem is EventApprovalsSystem {
  function preApproval(
    EventType eventType,
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal override {
  }

  function postApproval(
    EventType eventType,
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal override {
  }

  function approveEvent(
    EventType eventType,
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal override {}

  function approveMine(address caller, bytes32 voxelTypeId, VoxelCoord memory coord, bytes memory eventData) public override {
    super.approveMine(caller, voxelTypeId, coord, eventData);
  }

  function approveBuild(address caller, bytes32 voxelTypeId, VoxelCoord memory coord, bytes memory eventData) public override {
    super.approveBuild(caller, voxelTypeId, coord, eventData);
  }

  function approveActivate(address caller, bytes32 voxelTypeId, VoxelCoord memory coord, bytes memory eventData) public override {
    super.approveActivate(caller, voxelTypeId, coord, eventData);
  }

  function approveMove(address caller, bytes32 voxelTypeId, VoxelCoord memory coord, bytes memory eventData) public override {
    super.approveMove(caller, voxelTypeId, coord, eventData);
  }
}
