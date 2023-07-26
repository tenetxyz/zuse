// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { CHUNK } from "@tenet-contracts/src/Constants.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Coord, VoxelCoord } from "@tenet-contracts/src/Types.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { Position, PositionData, PositionTableId, VoxelType, VoxelTypeData } from "@tenet-contracts/src/codegen/Tables.sol";
import { BlockDirection } from "@tenet-contracts/src/Types.sol";

function getCallerNamespace(address caller) view returns (bytes16) {
  require(uint256(SystemRegistry.get(caller)) != 0, "Caller is not a system"); // cannot be called by an EOA
  bytes32 resourceSelector = SystemRegistry.get(caller);
  bytes16 callerNamespace = ResourceSelector.getNamespace(resourceSelector);
  return callerNamespace;
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

function getOppositeDirection(BlockDirection direction) pure returns (BlockDirection) {
  if (direction == BlockDirection.None) {
    return BlockDirection.None;
  } else if (direction == BlockDirection.Up) {
    return BlockDirection.Down;
  } else if (direction == BlockDirection.Down) {
    return BlockDirection.Up;
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

function getVoxelVariant(address world, bytes32 voxelTypeId, bytes32 entity) returns (bytes32 voxelVariantId) {
  // bytes4 voxelVariantSelector = VoxelTypeRegistry.get(voxelTypeNamespace, voxelTypeId).voxelVariantSelector;
  // bytes memory voxelVariantSelected = safeStaticCall(
  //   world,
  //   abi.encodeWithSelector(voxelVariantSelector, entity),
  //   "get voxel variant"
  // );
  // return abi.decode(voxelVariantSelected, (VoxelVariantsKey));
}

function enterVoxelIntoWorld(address world, bytes32 entity) {
  VoxelTypeData memory entityVoxelType = VoxelType.get(1, entity);
  // bytes4 enterWorldSelector = VoxelTypeRegistry
  //   .get(entityVoxelType.voxelTypeNamespace, entityVoxelType.voxelTypeId)
  //   .enterWorldSelector;
  // safeCall(world, abi.encodeWithSelector(enterWorldSelector, entity), "voxel enter world");
}

function exitVoxelFromWorld(address world, bytes32 entity) {
  VoxelTypeData memory entityVoxelType = VoxelType.get(1, entity);
  // bytes4 exitWorldSelector = VoxelTypeRegistry
  //   .get(entityVoxelType.voxelTypeNamespace, entityVoxelType.voxelTypeId)
  //   .exitWorldSelector;
  // safeCall(world, abi.encodeWithSelector(exitWorldSelector, entity), "voxel exit world");
}

function updateVoxelVariant(address world, bytes32 entity) {
  VoxelTypeData memory entityVoxelType = VoxelType.get(1, entity);
  // bytes32 voxelVariantId = getVoxelVariant(world, entityVoxelType.voxelTypeId, entity);
  // if (voxelVariantId != entityVoxelType.voxelVariantId) {
  //   VoxelType.set(1, entity, entityVoxelType.voxelTypeId, voxelVariantId);
  // }
}

function getEntitiesAtCoord(VoxelCoord memory coord) view returns (bytes32[][] memory) {
  return getKeysWithValue(PositionTableId, Position.encode(coord.x, coord.y, coord.z));
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
