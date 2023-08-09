// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { Event } from "./Event.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-contracts/src/Types.sol";
import { WorldConfig, OwnedBy, Position, PositionTableId, VoxelType, VoxelTypeData, OfSpawn, Spawn, SpawnData } from "@tenet-contracts/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { calculateChildCoords, getEntityAtCoord, positionDataToVoxelCoord } from "@tenet-contracts/src/Utils.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";

abstract contract MineEvent is Event {
  // Called by users
  function mine(bytes32 voxelTypeId, VoxelCoord memory coord) public virtual returns (uint32, bytes32);

  // Called by CA
  function mineVoxelType(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool mineChildren,
    bool mineParent
  ) public virtual returns (uint32, bytes32);

  function preEvent(bytes32 voxelTypeId, VoxelCoord memory coord) internal override {
    IWorld(_world()).approveMine(tx.origin, voxelTypeId, coord);
  }

  function postEvent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity
  ) internal override {
    bytes32 useParentEntity = IWorld(_world()).calculateParentEntity(scale, eventVoxelEntity);
    uint32 useParentScale = scale + 1;
    while (useParentEntity != 0) {
      bytes32 parentVoxelTypeId = VoxelType.getVoxelTypeId(useParentScale, useParentEntity);
      VoxelCoord memory parentCoord = positionDataToVoxelCoord(Position.get(useParentScale, useParentEntity));
      (uint32 minedParentScale, bytes32 minedParentEntity) = callEventHandler(
        parentVoxelTypeId,
        parentCoord,
        false,
        false
      );
      useParentEntity = IWorld(_world()).calculateParentEntity(minedParentScale, minedParentEntity);
    }
  }

  function runEventHandlerForParent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity
  ) internal override {}

  // function onEntityDoesntExist(
  //   bytes32 voxelTypeId,
  //   VoxelCoord memory coord,
  //   uint32 scale
  // ) internal override returns (bytes32) {
  //   if (scale == 2) {
  //     // For us 2 has he terrain gen (ie Grass, Dirt, etc.)
  //     bytes32 voxelToMine = getUniqueEntity();
  //     Position.set(scale, voxelToMine, coord.x, coord.y, coord.z);
  //     return voxelToMine;
  //   } else {
  //     // TODO: Support terrain gen at higher scales yet
  //     revert("Mining terrain at higher scales is not supported yet");
  //   }
  // }

  function preRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity
  ) internal override {
    // Enter World
    IWorld(_world()).exitCA(caAddress, scale, voxelTypeId, coord, eventVoxelEntity);
  }

  function postRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity
  ) internal override {}
}
