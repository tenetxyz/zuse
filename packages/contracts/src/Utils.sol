// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Coord, VoxelCoord } from "@tenet-contracts/src/Types.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { Position, PositionData, PositionTableId, VoxelType, VoxelTypeData } from "@tenet-contracts/src/codegen/Tables.sol";
import { BlockDirection } from "@tenet-contracts/src/Types.sol";

function calculateChildCoords(uint32 scale, VoxelCoord memory parentCoord) pure returns (VoxelCoord[] memory) {
  VoxelCoord[] memory childCoords = new VoxelCoord[](uint256(scale * scale * scale));
  uint256 index = 0;
  for (uint32 dz = 0; dz < scale; dz++) {
    for (uint32 dy = 0; dy < scale; dy++) {
      for (uint32 dx = 0; dx < scale; dx++) {
        childCoords[index] = VoxelCoord(
          parentCoord.x * int32(scale) + int32(dx),
          parentCoord.y * int32(scale) + int32(dy),
          parentCoord.z * int32(scale) + int32(dz)
        );
        index++;
      }
    }
  }
  return childCoords;
}

function calculateParentCoord(uint32 scale, VoxelCoord memory childCoord) pure returns (VoxelCoord memory) {
  int32 newX = childCoord.x / int32(scale);
  if (childCoord.x < 0) {
    newX -= 1; // We need to do this because Solidity rounds towards 0
  }
  int32 newY = childCoord.y / int32(scale);
  if (childCoord.y < 0) {
    newY -= 1; // We need to do this because Solidity rounds towards 0
  }
  int32 newZ = childCoord.z / int32(scale);
  if (childCoord.z < 0) {
    newZ -= 1; // We need to do this because Solidity rounds towards 0
  }
  return VoxelCoord(newX, newY, newZ);
}

function getEntityPositionStrict(bytes32 entity) view returns (PositionData memory) {
  bytes32[] memory positionKeyTuple = new bytes32[](1);
  positionKeyTuple[0] = bytes32((entity));
  require(hasKey(PositionTableId, positionKeyTuple), "Entity must have a position"); // even if its air, it must have a position
  return Position.get(1, entity);
}

function calculateBlockDirection(
  PositionData memory centerCoord,
  PositionData memory neighborCoord
) pure returns (BlockDirection) {
  if (neighborCoord.x == centerCoord.x && neighborCoord.y == centerCoord.y && neighborCoord.z == centerCoord.z) {
    return BlockDirection.None;
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

function getOppositeDirection(BlockDirection direction) pure returns (BlockDirection) {
  if (direction == BlockDirection.None) {
    return BlockDirection.None;
  } else if (direction == BlockDirection.North) {
    return BlockDirection.South;
  } else if (direction == BlockDirection.South) {
    return BlockDirection.North;
  } else if (direction == BlockDirection.East) {
    return BlockDirection.West;
  } else if (direction == BlockDirection.West) {
    return BlockDirection.East;
  } else {
    return BlockDirection.None;
  }
}

function getEntityAtCoord(uint32 scale, VoxelCoord memory coord) view returns (bytes32) {
  bytes32[][] memory allEntitiesAtCoord = getKeysWithValue(PositionTableId, Position.encode(coord.x, coord.y, coord.z));
  bytes32 entity;
  for (uint256 i = 0; i < allEntitiesAtCoord.length; i++) {
    if (uint256(allEntitiesAtCoord[i][0]) == scale) {
      if (uint256(entity) != 0) {
        revert("Found more than one entity at the same position");
      }
      entity = allEntitiesAtCoord[i][1];
    }
  }

  return entity;
}

function increaseVoxelTypeSpawnCount(bytes16 voxelTypeNamespace, bytes32 voxelTypeId) {
  // VoxelTypeRegistryData memory voxelTypeRegistryData = VoxelTypeRegistry.get(voxelTypeNamespace, voxelTypeId);
  // voxelTypeRegistryData.numSpawns += 1;
  // VoxelTypeRegistry.set(voxelTypeNamespace, voxelTypeId, voxelTypeRegistryData);
}

function getVoxelCoordStrict(bytes32 entity) view returns (VoxelCoord memory) {
  PositionData memory position = getEntityPositionStrict(entity);
  return VoxelCoord(position.x, position.y, position.z);
}

function entitiesToVoxelCoords(bytes32[] memory entities) returns (VoxelCoord[] memory) {
  VoxelCoord[] memory coords = new VoxelCoord[](entities.length);
  for (uint256 i; i < entities.length; i++) {
    PositionData memory position = Position.get(1, entities[i]);
    coords[i] = VoxelCoord(position.x, position.y, position.z);
  }
  return coords;
}

function entitiesToRelativeVoxelCoords(
  bytes32[] memory entities,
  VoxelCoord memory lowerSouthWestCorner
) returns (VoxelCoord[] memory) {
  VoxelCoord[] memory coords = entitiesToVoxelCoords(entities);
  VoxelCoord[] memory relativeCoords = new VoxelCoord[](coords.length);
  for (uint256 i; i < coords.length; i++) {
    relativeCoords[i] = VoxelCoord(
      coords[i].x - lowerSouthWestCorner.x,
      coords[i].y - lowerSouthWestCorner.y,
      coords[i].z - lowerSouthWestCorner.z
    );
  }
  return relativeCoords;
}

function positionDataToVoxelCoord(PositionData memory coord) pure returns (VoxelCoord memory) {
  return VoxelCoord(coord.x, coord.y, coord.z);
}
