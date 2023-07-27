// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { BlockDirection, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { NUM_VOXEL_NEIGHBOURS } from "@tenet-utils/src/Constants.sol";
import { getNeighbourCoords } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { CAPosition, CAPositionData, CAPositionTableId } from "@base-ca/src/codegen/Tables.sol";

function getEntityPositionStrict(address callerAddress, bytes32 entity) view returns (CAPositionData memory) {
  require(hasKey(CAPositionTableId, CAPosition.encodeKeyTuple(callerAddress, entity)), "Entity must have a position"); // even if its air, it must have a position
  return CAPosition.get(callerAddress, entity);
}

function getEntityAtCoord(address callerAddress, CAPositionData memory coord) view returns (bytes32) {
  bytes32[][] memory allEntitiesAtCoord = getKeysWithValue(
    CAPositionTableId,
    CAPosition.encode(coord.x, coord.y, coord.z)
  );
  bytes32 entity;
  for (uint256 i = 0; i < allEntitiesAtCoord.length; i++) {
    if (allEntitiesAtCoord[i][0] == bytes32(uint256(uint160(callerAddress)))) {
      if (uint256(entity) != 0) {
        revert("Found more than one entity at the same position");
      }
      entity = allEntitiesAtCoord[i][1];
    }
  }

  return entity;
}

function voxelCoordToPositionData(VoxelCoord memory coord) pure returns (CAPositionData memory) {
  return CAPositionData(coord.x, coord.y, coord.z);
}

function positionDataToVoxelCoord(CAPositionData memory coord) pure returns (VoxelCoord memory) {
  return VoxelCoord(coord.x, coord.y, coord.z);
}

function getNeighbours(
  address callerAddress,
  CAPositionData memory centerCoord
) returns (bytes32[] memory, BlockDirection[] memory) {
  bytes32[] memory neighbourEntityIds = new bytes32[](NUM_VOXEL_NEIGHBOURS);
  BlockDirection[] memory neighbourEntityDirections = new BlockDirection[](NUM_VOXEL_NEIGHBOURS);
  VoxelCoord[] memory neighbourCoords = getNeighbourCoords(positionDataToVoxelCoord(centerCoord));
  for (uint8 i = 0; i < neighbourCoords.length; i++) {
    CAPositionData memory neighbourCoord = voxelCoordToPositionData(neighbourCoords[i]);
    bytes32 entity = getEntityAtCoord(callerAddress, neighbourCoord);
    neighbourEntityIds[i] = entity;
    neighbourEntityDirections[i] = calculateBlockDirection(neighbourCoord, centerCoord);
  }
  return (neighbourEntityIds, neighbourEntityDirections);
}

function calculateBlockDirection(
  CAPositionData memory centerCoord,
  CAPositionData memory neighborCoord
) pure returns (BlockDirection) {
  if (neighborCoord.x == centerCoord.x && neighborCoord.y == centerCoord.y && neighborCoord.z == centerCoord.z) {
    return BlockDirection.None;
  } else if (neighborCoord.z > centerCoord.z) {
    if (neighborCoord.x > centerCoord.x) {
      return BlockDirection.NorthEast;
    } else if (neighborCoord.x < centerCoord.x) {
      return BlockDirection.NorthWest;
    } else {
      return BlockDirection.North;
    }
  } else if (neighborCoord.z < centerCoord.z) {
    if (neighborCoord.x > centerCoord.x) {
      return BlockDirection.SouthEast;
    } else if (neighborCoord.x < centerCoord.x) {
      return BlockDirection.SouthWest;
    } else {
      return BlockDirection.South;
    }
  } else if (neighborCoord.x > centerCoord.x) {
    return BlockDirection.East;
  } else if (neighborCoord.x < centerCoord.x) {
    return BlockDirection.West;
  } else {
    return BlockDirection.None;
  }
}
