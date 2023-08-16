// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { MineEvent } from "../prototypes/MineEvent.sol";
import { VoxelCoord, BodyEntity } from "@tenet-utils/src/Types.sol";
import { BodyType, OfSpawn, Spawn, SpawnData } from "@tenet-contracts/src/codegen/Tables.sol";
import { CHUNK_MAX_Y, CHUNK_MIN_Y } from "../Constants.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { getEntityAtCoord } from "../Utils.sol";

contract MineSystem is MineEvent {
  function callEventHandler(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren,
    bool runEventOnParent,
    bytes memory eventData
  ) internal override returns (uint32, bytes32) {
    return IWorld(_world()).mineBodyType(bodyTypeId, coord, runEventOnChildren, runEventOnParent, eventData);
  }

  // Called by users
  function mine(bytes32 bodyTypeId, VoxelCoord memory coord) public override returns (uint32, bytes32) {
    require(coord.y <= CHUNK_MAX_Y && coord.y >= CHUNK_MIN_Y, "out of chunk bounds");
    super.runEvent(bodyTypeId, coord, abi.encode(0));
  }

  // Called by CA
  function mineBodyType(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    bool mineChildren,
    bool mineParent,
    bytes memory eventData
  ) public override returns (uint32, bytes32) {
    return super.runEventHandler(bodyTypeId, coord, mineChildren, mineParent, eventData);
  }

  function postRunCA(
    address caAddress,
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes memory eventData
  ) internal override {
    if (bodyTypeId != AirVoxelID) {
      // TODO: Figure out how to add other airs
      // Can't own it since it became air, so we gift it
      IWorld(_world()).giftVoxel(bodyTypeId);
    }

    tryRemoveVoxelFromSpawn(scale, eventBodyEntity);
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
    BodyEntity[] memory existingVoxels = abi.decode(spawn.voxels, (BodyEntity[]));
    BodyEntity[] memory newVoxels = new BodyEntity[](existingVoxels.length - 1);
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

    bytes32 bodyTypeId = BodyType.getBodyTypeId(scale, entity);
    if (bodyTypeId == AirVoxelID) {
      // if it's air, then it's already clear
      return (0, 0);
    }

    return mine(bodyTypeId, coord);
  }
}
