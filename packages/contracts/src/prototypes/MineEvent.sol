// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { Event } from "./Event.sol";
import { VoxelCoord, BodyEntity } from "@tenet-utils/src/Types.sol";
import { WorldConfig, OwnedBy, Position, PositionTableId, BodyType, BodyTypeData, OfSpawn, Spawn, SpawnData } from "@tenet-contracts/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { calculateChildCoords, getEntityAtCoord, positionDataToVoxelCoord } from "@tenet-contracts/src/Utils.sol";
import { CABodyType, CABodyTypeData } from "@tenet-base-ca/src/codegen/tables/CABodyType.sol";
import { BodyTypeRegistry, BodyTypeRegistryData } from "@tenet-registry/src/codegen/tables/BodyTypeRegistry.sol";

abstract contract MineEvent is Event {
  // Called by users
  function mine(bytes32 bodyTypeId, VoxelCoord memory coord) public virtual returns (uint32, bytes32);

  // Called by CA
  function mineBodyType(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    bool mineChildren,
    bool mineParent,
    bytes memory eventData
  ) public virtual returns (uint32, bytes32);

  function preEvent(bytes32 bodyTypeId, VoxelCoord memory coord, bytes memory eventData) internal override {
    IWorld(_world()).approveMine(tx.origin, bodyTypeId, coord);
  }

  function postEvent(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes memory eventData
  ) internal override {
    bytes32 useParentEntity = IWorld(_world()).calculateParentEntity(scale, eventBodyEntity);
    uint32 useParentScale = scale + 1;
    while (useParentEntity != 0) {
      bytes32 parentBodyTypeId = BodyType.getBodyTypeId(useParentScale, useParentEntity);
      VoxelCoord memory parentCoord = positionDataToVoxelCoord(Position.get(useParentScale, useParentEntity));
      (uint32 minedParentScale, bytes32 minedParentEntity) = callEventHandler(
        parentBodyTypeId,
        parentCoord,
        false,
        false,
        eventData
      );
      useParentEntity = IWorld(_world()).calculateParentEntity(minedParentScale, minedParentEntity);
    }
  }

  function runEventHandlerForParent(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes memory eventData
  ) internal override {}

  function runEventHandlerForIndividualChildren(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes32 childBodyTypeId,
    VoxelCoord memory childCoord,
    bytes memory eventData
  ) internal override {
    bytes32 childBodyEntity = getEntityAtCoord(scale - 1, childCoord);
    if (childBodyEntity != 0) {
      // TODO: Update when using event data. Child event data should be different from parent event data
      runEventHandler(BodyType.getBodyTypeId(scale - 1, childBodyEntity), childCoord, true, false, eventData);
    }
  }

  function preRunCA(
    address caAddress,
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes memory eventData
  ) internal override {
    // Enter World
    IWorld(_world()).exitCA(caAddress, scale, bodyTypeId, coord, eventBodyEntity);
  }

  function runCA(address caAddress, uint32 scale, bytes32 eventBodyEntity, bytes memory eventData) internal override {
    IWorld(_world()).runCA(caAddress, scale, eventBodyEntity, bytes4(0));
  }
}
