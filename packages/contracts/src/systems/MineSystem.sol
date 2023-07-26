// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "@tenet-contracts/src/Types.sol";
import { OwnedBy, Position, PositionTableId, VoxelType, VoxelTypeData, OfSpawn, Spawn, SpawnData } from "@tenet-contracts/src/codegen/Tables.sol";
import { enterVoxelIntoWorld, exitVoxelFromWorld, updateVoxelVariant, getEntitiesAtCoord, getVoxelVariant } from "@tenet-contracts/src/Utils.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { safeStaticCallFunctionSelector } from "@tenet-utils/src/CallUtils.sol";
import { removeEntityFromArray } from "@tenet-utils/src/Utils.sol";
import { Utils } from "@latticexyz/world/src/Utils.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { console } from "forge-std/console.sol";

contract MineSystem is System {
  function mine(VoxelCoord memory coord, bytes32 voxelTypeId, bytes32 voxelVariantId) public returns (bytes32) {
    // require(voxelTypeId != AirID, "can not mine air");
    bytes32 AirID;
    // require(coord.y <= CHUNK_MAX_Y && coord.y >= CHUNK_MIN_Y, "out of chunk bounds");

    // Check ECS blocks at coord
    bytes32[][] memory entitiesAtPosition = getEntitiesAtCoord(coord);

    bytes32 voxelToMine;
    bytes32 airEntity;

    // Create an ECS voxel from this coord's terrain voxel
    bytes16 namespace = Utils.systemNamespace();

    if (entitiesAtPosition.length == 0) {
      // If there is no entity at this position, try mining the terrain voxel at this position
      // bytes memory occurrence = safeStaticCallFunctionSelector(
      //   _world(),
      //   Occurrence.get(voxelTypeId),
      //   abi.encode(coord)
      // );
      // require(occurrence.length > 0, "invalid terrain voxel type");
      // bytes32 occurenceVoxelVariantId = abi.decode(occurrence, (bytes32));
      // require(occurenceVoxelVariantId == voxelVariantId, "invalid terrain voxel variant");

      // Create an ECS voxel from this coord's terrain voxel
      voxelToMine = getUniqueEntity();
      // in terrain gen, we know its our system namespace and we validated it above using the Occurrence table
      VoxelType.set(1, voxelToMine, voxelTypeId, voxelVariantId);
    } else {
      // Else, mine the non-air entity voxel at this position
      require(entitiesAtPosition.length == 1, "there should only be one entity at this position");
      voxelToMine = entitiesAtPosition[0][1];
      VoxelTypeData memory voxelTypeData = VoxelType.get(1, voxelToMine);
      require(voxelToMine != 0, "We found no voxels at that position");
      require(
        voxelTypeData.voxelTypeId == voxelTypeId && voxelTypeData.voxelVariantId == voxelVariantId,
        "The voxel at this position is not the same as the voxel you are trying to mine"
      );
      tryRemoveVoxelFromSpawn(voxelToMine);
      Position.deleteRecord(1, voxelToMine);
      exitVoxelFromWorld(_world(), voxelToMine);
      VoxelType.set(1, voxelToMine, voxelTypeData.voxelTypeId, "");
    }

    // Place an air voxel at this position
    airEntity = getUniqueEntity();
    // TODO: We don't need necessarily need to get the air voxel type from the registry, we could just use the AirID
    // Maybe consider doing this for performance reasons
    VoxelType.set(1, airEntity, AirID, AirID);
    Position.set(1, airEntity, coord.x, coord.y, coord.z);
    enterVoxelIntoWorld(_world(), airEntity);
    updateVoxelVariant(_world(), airEntity);

    OwnedBy.set(voxelToMine, addressToEntityKey(_msgSender()));
    // Since numUniqueVoxelTypesIOwn is quadratic in gas (based on how many voxels you own), running this function could use up all your gas. So it's commented
    //    require(IWorld(_world()).tenet_GiftVoxelSystem_numUniqueVoxelTypesIOwn() <= 36, "you can only own 36 voxel types at a time");

    // Run voxel interaction logic
    IWorld(_world()).tenet_VoxInteractSys_runInteractionSystems(airEntity);

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
    bytes32 AirID;
    bytes32[][] memory entitiesAtPosition = getEntitiesAtCoord(coord);
    bytes32 minedEntity = 0;
    for (uint256 i = 0; i < entitiesAtPosition.length; i++) {
      bytes32 entity = entitiesAtPosition[i][1];

      VoxelTypeData memory voxelTypeData = VoxelType.get(1, entity);
      if (voxelTypeData.voxelTypeId == AirID) {
        // if it's air, then it's already clear
        continue;
      }
      minedEntity = mine(coord, voxelTypeData.voxelTypeId, voxelTypeData.voxelVariantId);
    }
    return minedEntity;
  }
}
