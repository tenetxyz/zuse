// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "@tenet-contracts/src/Types.sol";
import { WorldConfig, OwnedBy, Position, PositionTableId, VoxelType, VoxelTypeData, OfSpawn, Spawn, SpawnData } from "@tenet-contracts/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { calculateChildCoords, getEntityAtCoord, getEntitiesAtCoord } from "@tenet-contracts/src/Utils.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { removeEntityFromArray } from "@tenet-utils/src/Utils.sol";
import { Utils } from "@latticexyz/world/src/Utils.sol";
import { CHUNK_MAX_Y, CHUNK_MIN_Y } from "../Constants.sol";
import { exitWorld } from "@tenet-base-ca/src/CallUtils.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

contract MineSystem is System {
  function mine(bytes32 voxelTypeId, VoxelCoord memory coord) public returns (bytes32) {
    require(coord.y <= CHUNK_MAX_Y && coord.y >= CHUNK_MIN_Y, "out of chunk bounds");
    require(IWorld(_world()).isVoxelTypeAllowed(voxelTypeId), "Voxel type not allowed in this world");
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

    if (scale > 1) {
      // Read the ChildTypes in this CA address
      bytes32[] memory childVoxelTypeIds = voxelTypeData.childVoxelTypeIds;
      // TODO: Make this general by using cube root
      require(childVoxelTypeIds.length == 8, "Invalid length of child voxel type ids");
      // TODO: move this to a library
      VoxelCoord[] memory eightBlockVoxelCoords = calculateChildCoords(2, coord);
      for (uint8 i = 0; i < 8; i++) {
        // mine(childVoxelTypeIds[i], eightBlockVoxelCoords[i]);
        bytes32 childVoxelToMine = getEntityAtCoord(scale, eightBlockVoxelCoords[i]);
        if (childVoxelToMine != 0) {
          mine(VoxelType.getVoxelTypeId(scale, childVoxelToMine), eightBlockVoxelCoords[i]);
        }
      }
    }

    exitWorld(caAddress, voxelTypeId, coord, voxelToMine);

    // Set initial voxel type
    CAVoxelTypeData memory entityCAVoxelType = CAVoxelType.get(IStore(caAddress), _world(), voxelToMine);
    VoxelType.set(scale, voxelToMine, entityCAVoxelType.voxelTypeId, entityCAVoxelType.voxelVariantId);

    IWorld(_world()).runCA(caAddress, scale, voxelToMine);

    // Can't own it since it became air, so we gift it
    IWorld(_world()).giftVoxel(voxelTypeId);

    return voxelToMine;
  }

  function tryRemoveVoxelFromSpawn(bytes32 voxel) internal {
    bytes32 spawnId = OfSpawn.get(voxel);
    if (spawnId == 0) {
      return;
    }

    OfSpawn.deleteRecord(voxel);
    SpawnData memory spawn = Spawn.get(spawnId);
    // should we check to see if the entity is in the array before trying to remove it?
    // I think it's ok to assume it's there, since this is the only way to remove a voxel from a spawn
    bytes32[] memory newVoxels = removeEntityFromArray(spawn.voxels, voxel);

    if (newVoxels.length == 0) {
      // no more voxels of this spawn are in the world, so delete it
      Spawn.deleteRecord(spawnId);
    } else {
      // This spawn is still in the world, but it has been modified (since a voxel was removed)
      Spawn.setVoxels(spawnId, newVoxels);
      Spawn.setIsModified(spawnId, true);
    }
  }

  function clearCoord(VoxelCoord memory coord) public returns (bytes32) {
    bytes32[][] memory entitiesAtPosition = getEntitiesAtCoord(coord);
    bytes32 minedEntity = 0;
    for (uint256 i = 0; i < entitiesAtPosition.length; i++) {
      uint32 scale = uint32(uint256(entitiesAtPosition[i][0]));
      bytes32 entity = entitiesAtPosition[i][1];

      VoxelTypeData memory voxelTypeData = VoxelType.get(scale, entity);
      if (voxelTypeData.voxelTypeId == AirVoxelID) {
        // if it's air, then it's already clear
        continue;
      }
      minedEntity = mine(voxelTypeData.voxelTypeId, coord);
    }
    return minedEntity;
  }
}
