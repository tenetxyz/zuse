// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelEntity, EntityEventData } from "@tenet-utils/src/Types.sol";
import { hasEntity } from "@tenet-utils/src/Utils.sol";
import { KeysInTable } from "@latticexyz/world/src/modules/keysintable/tables/KeysInTable.sol";
import { callOrRevert } from "@tenet-utils/src/CallUtils.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { Interactions, InteractionsTableId } from "@tenet-base-world/src/codegen/tables/Interactions.sol";
import { MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH, MAX_UNIQUE_ENTITY_INTERACTIONS_RUN, MAX_SAME_VOXEL_INTERACTION_RUN } from "@tenet-utils/src/Constants.sol";
import { Position, PositionData } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { positionDataToVoxelCoord, getEntityAtCoord, calculateChildCoords, calculateParentCoord } from "@tenet-base-world/src/Utils.sol";
import { VoxelType, VoxelTypeData } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { getEntityAtCoord, calculateChildCoords, calculateParentCoord } from "@tenet-base-world/src/Utils.sol";
import { runInteraction, enterWorld, exitWorld, activateVoxel, moveLayer, updateVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";

abstract contract ObjectSystem is System {
  function getRegistryAddress() internal pure override returns (address);

  function decodeToObjectProperties(bytes memory data) external pure returns (ObjectProperties memory) {
    return abi.decode(data, (ObjectProperties));
  }

  function enterWorld(
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) public virtual returns (ObjectProperties memory requestedProperties) {
    bytes4 objectEnterWorldSelector = getEnterWorldSelector(IStore(getRegistryAddress()), objectTypeId);
    require(objectEnterWorldSelector != bytes4(0), "Object enterWorld not defined");

    (bool enterWorldSuccess, bytes memory enterWorldReturnData) = safeCall(
      _world(),
      abi.encodeWithSelector(objectEnterWorldSelector, coord, objectEntityId),
      "object enter world"
    );
    if (enterWorldSuccess) {
      try this.decodeToObjectProperties(enterWorldReturnData) returns (ObjectProperties memory decodedValue) {
        requestedProperties = decodedValue;
      } catch {}
    }

    return requestedProperties;
  }

  function moveCA(
    address caAddress,
    VoxelEntity memory newEntity,
    bytes32 voxelTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord
  ) public virtual {
    (bytes32[] memory neighbourEntities, ) = IWorld(_world()).calculateNeighbourEntities(newEntity);
    bytes32[] memory childEntityIds = IWorld(_world()).calculateChildEntities(newEntity);
    bytes32 parentEntity = IWorld(_world()).calculateParentEntity(newEntity);
    moveLayer(
      caAddress,
      voxelTypeId,
      oldCoord,
      newCoord,
      newEntity.entityId,
      neighbourEntities,
      childEntityIds,
      parentEntity
    );
  }

  function exitCA(
    address caAddress,
    VoxelEntity memory entity,
    bytes32 voxelTypeId,
    VoxelCoord memory coord
  ) public virtual {
    (bytes32[] memory neighbourEntities, ) = IWorld(_world()).calculateNeighbourEntities(entity);
    bytes32[] memory childEntityIds = IWorld(_world()).calculateChildEntities(entity);
    bytes32 parentEntity = IWorld(_world()).calculateParentEntity(entity);
    exitWorld(caAddress, voxelTypeId, coord, entity.entityId, neighbourEntities, childEntityIds, parentEntity);
  }
}
