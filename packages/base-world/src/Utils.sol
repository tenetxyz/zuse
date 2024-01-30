// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { hasKey } from "@latticexyz/world/src/modules/haskeys/hasKey.sol";

import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { Position, PositionData, PositionTableId } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { ObjectEntity, ObjectEntityTableId } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";

import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getVonNeumannNeighbours, getMooreNeighbours } from "@tenet-utils/src/VoxelCoordUtils.sol";

function positionDataToVoxelCoord(PositionData memory coord) pure returns (VoxelCoord memory) {
  return VoxelCoord(coord.x, coord.y, coord.z);
}

function getEntityIdFromObjectEntityId(IStore store, bytes32 objectEntityId) view returns (bytes32) {
  bytes32[][] memory allEntities = getKeysWithValue(store, ObjectEntityTableId, ObjectEntity.encode(objectEntityId));
  require(allEntities.length == 1, "Found more than one entity with the same objectEntityId");
  return allEntities[0][0];
}

function getVoxelCoord(IStore store, bytes32 objectEntityId) view returns (VoxelCoord memory) {
  PositionData memory position = Position.get(store, getEntityIdFromObjectEntityId(store, objectEntityId));
  return positionDataToVoxelCoord(position);
}

function getObjectType(IStore store, bytes32 objectEntityId) view returns (bytes32) {
  return ObjectType.get(store, getEntityIdFromObjectEntityId(store, objectEntityId));
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

function getEntityPositionStrict(IStore store, bytes32 entityId) view returns (PositionData memory) {
  require(hasKey(store, PositionTableId, Position.encodeKeyTuple(entityId)), "Entity must have a position");
  return Position.get(store, entityId);
}

function getVoxelCoordStrict(IStore store, bytes32 entityId) view returns (VoxelCoord memory) {
  PositionData memory position = getEntityPositionStrict(store, entityId);
  return positionDataToVoxelCoord(position);
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

function getMooreNeighbourEntities(
  IStore store,
  bytes32 centerEntityId,
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
