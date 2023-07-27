// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { CA_ENTER_WORLD_SIG, CA_EXIT_WORLD_SIG, CA_RUN_INTERACTION_SIG } from "./Constants.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { CAPosition, CAPositionData, CAPositionTableId } from "@base-ca/src/codegen/Tables.sol";

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

function getEntityPositionStrict(address callerAddress, bytes32 entity) view returns (CAPositionData memory) {
  require(hasKey(CAPositionTableId, CAPosition.encodeKeyTuple(callerAddress, entity)), "Entity must have a position"); // even if its air, it must have a position
  return CAPosition.get(callerAddress, entity);
}

function calculateBlockDirection(
  CAPositionData memory centerCoord,
  CAPositionData memory neighborCoord
) pure returns (BlockDirection) {
  if (neighborCoord.x == centerCoord.x && neighborCoord.y == centerCoord.y && neighborCoord.z == centerCoord.z) {
    return BlockDirection.None;
  } else if (neighborCoord.y > centerCoord.y) {
    return BlockDirection.Up;
  } else if (neighborCoord.y < centerCoord.y) {
    return BlockDirection.Down;
  } else if (neighborCoord.z > centerCoord.z) {
    return BlockDirection.North;
  } else if (neighborCoord.z < centerCoord.z) {
    return BlockDirection.South;
  } else if (neighborCoord.x > centerCoord.x) {
    return BlockDirection.East;
  } else if (neighborCoord.x < centerCoord.x) {
    return BlockDirection.West;
  } else {
    return BlockDirection.None;
  }
}
