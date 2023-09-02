// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { MineEvent } from "@tenet-base-world/src/prototypes/MineEvent.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { VoxelType, OfSpawn, Spawn, SpawnData } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelTypeData } from "@tenet-utils/src/Types.sol";
import { CHUNK_MAX_Y, CHUNK_MIN_Y } from "../Constants.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { getEntityAtCoord } from "@tenet-base-world/src/Utils.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";

contract MineSystem is MineEvent {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function callEventHandler(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren,
    bool runEventOnParent,
    bytes memory eventData
  ) internal override returns (uint32, bytes32) {
    return IWorld(_world()).mineVoxelType(voxelTypeId, coord, runEventOnChildren, runEventOnParent, eventData);
  }

  // Called by users
  function mine(bytes32 voxelTypeId, VoxelCoord memory coord) public override returns (uint32, bytes32) {
    require(coord.y <= CHUNK_MAX_Y && coord.y >= CHUNK_MIN_Y, "out of chunk bounds");
    super.runEvent(voxelTypeId, coord, abi.encode(0));
  }

  // Called by CA
  function mineVoxelType(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool mineChildren,
    bool mineParent,
    bytes memory eventData
  ) public override returns (uint32, bytes32) {
    return super.runEventHandler(voxelTypeId, coord, mineChildren, mineParent, eventData);
  }

  function postRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity,
    bytes memory eventData
  ) internal override {
    if (voxelTypeId != AirVoxelID) {
      // TODO: Figure out how to add other airs
      // Can't own it since it became air, so we gift it
      IWorld(_world()).giftVoxel(voxelTypeId);
    }

    tryRemoveVoxelFromSpawn(scale, eventVoxelEntity);
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

  function clearCoord(uint32 scale, VoxelCoord memory coord) public returns (uint32, bytes32) {
    bytes32 entity = getEntityAtCoord(scale, coord);

    bytes32 voxelTypeId = VoxelType.getVoxelTypeId(scale, entity);
    if (voxelTypeId == AirVoxelID) {
      // if it's air, then it's already clear
      return (0, 0);
    }

    return mine(voxelTypeId, coord);
  }
}
