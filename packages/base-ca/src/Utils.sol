// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { BlockDirection, VoxelCoord, InteractionSelector } from "@tenet-utils/src/Types.sol";
import { getVonNeumannNeighbours, calculateBlockDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { CAPosition, CAPositionData, CAPositionTableId } from "@tenet-base-ca/src/codegen/tables/CAPosition.sol";
import { CAVoxelType } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { CAEntityReverseMapping, CAEntityReverseMappingTableId, CAEntityReverseMappingData } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";
import { getInteractionSelectors } from "@tenet-registry/src/Utils.sol";

function entityToCAEntity(address callerAddress, bytes32 entity) view returns (bytes32) {
  if (uint256(entity) == 0) {
    return entity;
  }
  require(
    hasKey(CAEntityMappingTableId, CAEntityMapping.encodeKeyTuple(callerAddress, entity)),
    "Entity must be mapped to a CAEntity"
  );
  return CAEntityMapping.get(callerAddress, entity);
}

function caEntityToEntity(bytes32 caEntity) view returns (bytes32) {
  if (caEntity == 0) {
    return caEntity;
  }
  require(
    hasKey(CAEntityReverseMappingTableId, CAEntityReverseMapping.encodeKeyTuple(caEntity)),
    "CAEntity must be mapped to an entity"
  );
  return CAEntityReverseMapping.getEntity(caEntity);
}

function entityArrayToCAEntityArray(address callerAddress, bytes32[] memory entities) view returns (bytes32[] memory) {
  bytes32[] memory caEntities = new bytes32[](entities.length);
  for (uint256 i = 0; i < entities.length; i++) {
    caEntities[i] = entityToCAEntity(callerAddress, entities[i]);
  }
  return caEntities;
}

function caEntityArrayToEntityArray(bytes32[] memory caEntities) view returns (bytes32[] memory) {
  bytes32[] memory entities = new bytes32[](caEntities.length);
  for (uint256 i = 0; i < caEntities.length; i++) {
    entities[i] = caEntityToEntity(caEntities[i]);
  }
  return entities;
}

function getCAVoxelType(bytes32 caEntity) view returns (bytes32) {
  CAEntityReverseMappingData memory entityData = CAEntityReverseMapping.get(caEntity);
  return CAVoxelType.getVoxelTypeId(entityData.callerAddress, entityData.entity);
}

function getCAEntityIsAgent(address registryAddress, bytes32 caEntity) view returns (bool) {
  CAEntityReverseMappingData memory entityData = CAEntityReverseMapping.get(caEntity);
  bytes32 voxelTypeId = CAVoxelType.getVoxelTypeId(entityData.callerAddress, entityData.entity);
  InteractionSelector[] memory interactionSelectors = getInteractionSelectors(IStore(registryAddress), voxelTypeId);
  return interactionSelectors.length > 1;
}

function getEntityPositionStrict(IStore store, address callerAddress, bytes32 entity) view returns (VoxelCoord memory) {
  require(
    hasKey(store, CAPositionTableId, CAPosition.encodeKeyTuple(callerAddress, entity)),
    "Entity must have a position"
  ); // even if its air, it must have a position
  return positionDataToVoxelCoord(CAPosition.get(store, callerAddress, entity));
}

function getCAEntityPositionStrict(IStore store, bytes32 caEntity) view returns (VoxelCoord memory) {
  CAEntityReverseMappingData memory entityData = CAEntityReverseMapping.get(store, caEntity);
  return getEntityPositionStrict(store, entityData.callerAddress, entityData.entity);
}

function getEntityAtCoord(IStore store, address callerAddress, VoxelCoord memory coord) view returns (bytes32) {
  bytes32[][] memory allEntitiesAtCoord = getKeysWithValue(
    store,
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

function getCAEntityAtCoord(IStore store, address callerAddress, VoxelCoord memory coord) view returns (bytes32) {
  return entityToCAEntity(callerAddress, getEntityAtCoord(store, callerAddress, coord));
}

function voxelCoordToPositionData(VoxelCoord memory coord) pure returns (CAPositionData memory) {
  return CAPositionData(coord.x, coord.y, coord.z);
}

function positionDataToVoxelCoord(CAPositionData memory coord) pure returns (VoxelCoord memory) {
  return VoxelCoord(coord.x, coord.y, coord.z);
}

function getCANeighbours(
  IStore store,
  address callerAddress,
  VoxelCoord memory centerCoord
) returns (bytes32[] memory, BlockDirection[] memory) {
  VoxelCoord[] memory neighbourCoords = getVonNeumannNeighbours(centerCoord);
  bytes32[] memory neighbourEntityIds = new bytes32[](neighbourCoords.length);
  BlockDirection[] memory neighbourEntityDirections = new BlockDirection[](neighbourCoords.length);
  for (uint8 i = 0; i < neighbourCoords.length; i++) {
    bytes32 entity = getCAEntityAtCoord(store, callerAddress, neighbourCoords[i]);
    neighbourEntityIds[i] = entity;
    neighbourEntityDirections[i] = calculateBlockDirection(neighbourCoords[i], centerCoord);
  }
  return (neighbourEntityIds, neighbourEntityDirections);
}
