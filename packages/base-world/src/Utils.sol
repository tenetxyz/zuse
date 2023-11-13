// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Coord, VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { VoxelEntity } from "@tenet-utils/src/Types.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { Position, PositionData, PositionTableId } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { VoxelType, VoxelTypeData } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { getVonNeumannNeighbours } from "@tenet-utils/src/VoxelCoordUtils.sol";

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

function getMooreNeighbourEntities(
  IStore store,
  bytes32 centerEntityId
  uint8 neighbourRadius
) view returns (bytes32[] memory, VoxelCoord[] memory) {
  VoxelCoord memory centerCoord = positionDataToVoxelCoord(Position.get(store, centerEntityId));
  VoxelCoord[] memory neighbourCoords = getMooreNeighbours(centerCoord, neighbourRadius);
  bytes32[] memory neighbourEntities = new bytes32[](neighbourCoords.length);
  for (uint i = 0; i < neighbourCoords.length; i++) {
    bytes32 neighbourEntity = getEntityAtCoord(store, neighbourCoords[i]);
    if (uint256(neighbourEntity) != 0) {
      neighbourEntities[i] = neighbourEntity;
    }
  }
  return (neighbourEntities, neighbourCoords);
}

function getVonNeumannNeighbourEntities(
  IStore store,
  bytes32 centerEntityId
) view returns (bytes32[] memory, VoxelCoord[] memory) {
  VoxelCoord memory centerCoord = positionDataToVoxelCoord(Position.get(store, centerEntityId));
  VoxelCoord[] memory neighbourCoords = getVonNeumannNeighbours(centerCoord);
  bytes32[] memory neighbourEntities = new bytes32[](neighbourCoords.length);

  for (uint i = 0; i < neighbourCoords.length; i++) {
    bytes32 neighbourEntity = getEntityAtCoord(store, neighbourCoords[i]);
    if (uint256(neighbourEntity) != 0) {
      neighbourEntities[i] = neighbourEntity;
    }
  }

  return (neighbourEntities, neighbourCoords);
}

function getEntityAtCoord(IStore store, VoxelCoord memory coord) view returns (bytes32) {
  bytes32[][] memory allEntitiesAtCoord = getKeysWithValue(
    store,
    PositionTableId,
    Position.encode(coord.x, coord.y, coord.z)
  );
  bytes32 entity;
  require(allEntitiesAtCoord.length <= 1, "Found more than one entity at the same position");
  if (allEntitiesAtCoord.length == 1) {
    entity = allEntitiesAtCoord[0][0];
  }

  return entity;
}

function getEntityPositionStrict(VoxelEntity memory entity) view returns (PositionData memory) {
  uint32 scale = entity.scale;
  bytes32 entityId = entity.entityId;
  bytes32[] memory positionKeyTuple = new bytes32[](2);
  positionKeyTuple[0] = bytes32(uint256(scale));
  positionKeyTuple[1] = (entityId);
  require(hasKey(PositionTableId, positionKeyTuple), "Entity must have a position"); // even if its air, it must have a position
  return Position.get(scale, entityId);
}

function getEntityPositionStrict(IStore store, VoxelEntity memory entity) view returns (PositionData memory) {
  uint32 scale = entity.scale;
  bytes32 entityId = entity.entityId;
  bytes32[] memory positionKeyTuple = new bytes32[](2);
  positionKeyTuple[0] = bytes32(uint256(scale));
  positionKeyTuple[1] = (entityId);
  require(hasKey(store, PositionTableId, positionKeyTuple), "Entity must have a position"); // even if its air, it must have a position
  return Position.get(store, scale, entityId);
}

function getVoxelCoordStrict(VoxelEntity memory entity) view returns (VoxelCoord memory) {
  PositionData memory position = getEntityPositionStrict(entity);
  return positionDataToVoxelCoord(position);
}

function getVoxelCoordStrict(IStore store, VoxelEntity memory entity) view returns (VoxelCoord memory) {
  PositionData memory position = getEntityPositionStrict(store, entity);
  return positionDataToVoxelCoord(position);
}

function entitiesToVoxelCoords(bytes32[] memory entities) view returns (VoxelCoord[] memory) {
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
) view returns (VoxelCoord[] memory) {
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
