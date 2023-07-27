// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { CA_ENTER_WORLD_SIG, CA_EXIT_WORLD_SIG, CA_RUN_INTERACTION_SIG } from "./Constants.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

function mineWorld(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord) returns (bytes memory) {
  return
    safeCall(
      callerAddress,
      abi.encodeWithSignature("mine(bytes32,(int32,int32,int32))", voxelTypeId, coord),
      string(abi.encode("mine ", voxelTypeId, " ", coord))
    );
}

function buildWorld(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord) returns (bytes memory) {
  return
    safeCall(
      callerAddress,
      abi.encodeWithSignature("buildVoxelType(bytes32,(int32,int32,int32))", voxelTypeId, coord),
      string(abi.encode("buildVoxelType ", voxelTypeId, " ", coord))
    );
}

function enterWorld(
  address caAddress,
  bytes32 voxelTypeId,
  VoxelCoord memory coord,
  bytes32 entity
) returns (bytes memory) {
  return
    safeCall(
      caAddress,
      abi.encodeWithSignature(CA_ENTER_WORLD_SIG, voxelTypeId, coord, entity),
      string(abi.encode("enterWorld ", voxelTypeId, " ", coord, " ", entity))
    );
}

function exitWorld(
  address caAddress,
  bytes32 voxelTypeId,
  VoxelCoord memory coord,
  bytes32 entity
) returns (bytes memory) {
  return
    safeCall(
      caAddress,
      abi.encodeWithSignature(CA_EXIT_WORLD_SIG, voxelTypeId, coord, entity),
      string(abi.encode("exitWorld ", voxelTypeId, " ", coord, " ", entity))
    );
}

function runInteraction(
  address caAddress,
  bytes32 entity,
  bytes32[] memory neighbourEntityIds,
  bytes32[] memory childEntityIds,
  bytes32 parentEntity
) returns (bytes memory) {
  return
    safeCall(
      caAddress,
      abi.encodeWithSignature(CA_RUN_INTERACTION_SIG, entity, neighbourEntityIds, childEntityIds, parentEntity),
      string(abi.encode("runInteraction ", entity, " ", neighbourEntityIds, " ", childEntityIds, " ", parentEntity))
    );
}
