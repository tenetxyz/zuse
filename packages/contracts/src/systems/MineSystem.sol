// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-contracts/src/Types.sol";
import { WorldConfig, OwnedBy, Position, PositionTableId, VoxelType, VoxelTypeData, OfSpawn, Spawn, SpawnData } from "@tenet-contracts/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { calculateChildCoords, getEntityAtCoord, positionDataToVoxelCoord } from "@tenet-contracts/src/Utils.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { Utils } from "@latticexyz/world/src/Utils.sol";
import { CHUNK_MAX_Y, CHUNK_MIN_Y } from "../Constants.sol";
import { AirVoxelID, AirVoxelVariantID } from "@tenet-base-ca/src/Constants.sol";

contract MineSystem is System {
  function mine(bytes32 voxelTypeId, VoxelCoord memory coord) public returns (uint32, bytes32) {
    (uint32 scale, bytes32 voxelToMine) = mineVoxelType(voxelTypeId, coord, true);

    bytes32 useParentEntity = IWorld(_world()).calculateParentEntity(scale, voxelToMine);
    uint32 useParentScale = scale + 1;
    while (useParentEntity != 0) {
      bytes32 parentVoxelTypeId = VoxelType.getVoxelTypeId(useParentScale, useParentEntity);
      VoxelCoord memory parentCoord = positionDataToVoxelCoord(Position.get(useParentScale, useParentEntity));
      (uint32 minedParentScale, bytes32 minedParentEntity) = mineVoxelType(parentVoxelTypeId, parentCoord, false);
      useParentEntity = IWorld(_world()).calculateParentEntity(minedParentScale, minedParentEntity);
    }
    return (scale, voxelToMine);
  }

  function mineVoxelType(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool mineChildren
  ) public returns (uint32, bytes32) {
    require(coord.y <= CHUNK_MAX_Y && coord.y >= CHUNK_MIN_Y, "out of chunk bounds");
    require(IWorld(_world()).isVoxelTypeAllowed(voxelTypeId), "MineSystem: Voxel type not allowed in this world");
    VoxelTypeRegistryData memory voxelTypeData = VoxelTypeRegistry.get(IStore(REGISTRY_ADDRESS), voxelTypeId);
    address caAddress = WorldConfig.get(voxelTypeId);

    uint32 scale = voxelTypeData.scale;
    bytes32 voxelToMine = getEntityAtCoord(scale, coord);
    if (voxelToMine == 0) {
      if (scale == 2) {
        // For us 2 has he terrain gen (ie Grass, Dirt, etc.)
        voxelToMine = getUniqueEntity();
        Position.set(scale, voxelToMine, coord.x, coord.y, coord.z);
      } else {
        // TODO: Support terrain gen at higher scales yet
        revert("Mining terrain at higher scales is not supported yet");
      }
    }

    if (mineChildren && scale > 1) {
      // Read the ChildTypes in this CA address
      bytes32[] memory childVoxelTypeIds = voxelTypeData.childVoxelTypeIds;
      // TODO: Make this general by using cube root
      require(childVoxelTypeIds.length == 8, "Invalid length of child voxel type ids");
      // TODO: move this to a library
      VoxelCoord[] memory eightBlockVoxelCoords = calculateChildCoords(2, coord);
      for (uint8 i = 0; i < 8; i++) {
        // mine(childVoxelTypeIds[i], eightBlockVoxelCoords[i]);
        bytes32 childVoxelToMine = getEntityAtCoord(scale - 1, eightBlockVoxelCoords[i]);
        if (childVoxelToMine != 0) {
          mineVoxelType(VoxelType.getVoxelTypeId(scale - 1, childVoxelToMine), eightBlockVoxelCoords[i], true);
        }
      }
    }

    IWorld(_world()).exitCA(caAddress, scale, voxelTypeId, coord, voxelToMine);

    // Set initial voxel type
    CAVoxelTypeData memory entityCAVoxelType = CAVoxelType.get(IStore(caAddress), _world(), voxelToMine);
    VoxelType.set(scale, voxelToMine, entityCAVoxelType.voxelTypeId, entityCAVoxelType.voxelVariantId);

    IWorld(_world()).runCA(caAddress, scale, voxelToMine);

    if (voxelTypeId != AirVoxelID) { // TODO: Figure out how to add other airs
      // Can't own it since it became air, so we gift it
      IWorld(_world()).giftVoxel(voxelTypeId);
    }

    tryRemoveVoxelFromSpawn(scale, voxelToMine);

    return (scale, voxelToMine);
  }

  function tryRemoveVoxelFromSpawn(uint32 scale, bytes32 voxel) internal {
    bytes32 spawnId = OfSpawn.get(scale, voxel);
    if (spawnId == 0) {
      return;
    }

    OfSpawn.deleteRecord(scale, voxel);
    SpawnData memory spawn = Spawn.get(spawnId);

    // should we check to see if the entity is in the array before trying to remove it?
    // I think it's ok to assume it's there, since this is the only way to remove a voxel from a spawn
    VoxelEntity[] memory existingVoxels = abi.decode(spawn.voxels, (VoxelEntity[]));
    VoxelEntity[] memory newVoxels = new VoxelEntity[](existingVoxels.length - 1);
    uint index = 0;

    // Copy elements from the original array to the updated array, excluding the entity
    for (uint i = 0; i < existingVoxels.length; i++) {
      if (existingVoxels[i].scale != scale || existingVoxels[i].entityId != voxel) {
        newVoxels[index] = existingVoxels[i];
        index++;
      }
    }

    if (newVoxels.length == 0) {
      // no more voxels of this spawn are in the world, so delete it
      Spawn.deleteRecord(spawnId);
    } else {
      // This spawn is still in the world, but it has been modified (since a voxel was removed)
      Spawn.setVoxels(spawnId, abi.encode(newVoxels));
      Spawn.setIsModified(spawnId, true);
    }
  }
}
