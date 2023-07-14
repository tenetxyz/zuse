// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, BaseCreation } from "../Types.sol";
import { OwnedBy, Position, PositionTableId, VoxelType, VoxelTypeData, OfSpawn, Spawn, SpawnData, Creation, CreationData } from "@tenet-contracts/src/codegen/Tables.sol";
import { enterVoxelIntoWorld, getEntitiesAtCoord, add, int32ToString, increaseVoxelTypeSpawnCount, updateVoxelVariant, voxelCoordsAreEqual } from "../Utils.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { console } from "forge-std/console.sol";
import { CHUNK_MAX_Y, CHUNK_MIN_Y } from "../Constants.sol";

contract SpawnSystem is System {
  function spawn(VoxelCoord memory lowerSouthWestCorner, bytes32 creationId) public returns (bytes32) {
    // relPosX = all the relative position X coordinates
    (VoxelTypeData[] memory voxelTypes, VoxelCoord[] memory relativeVoxelCoords) = getAllVoxels(creationId);

    SpawnData memory spawnData;
    bytes32[] memory spawnVoxels = new bytes32[](voxelTypes.length);
    spawnData.creationId = creationId;
    spawnData.lowerSouthWestCorner = abi.encode(lowerSouthWestCorner);
    spawnData.isModified = false;

    bytes32 spawnId = getUniqueEntity();
    for (uint i = 0; i < voxelTypes.length; i++) {
      VoxelCoord memory relativeCoord = relativeVoxelCoords[i];
      VoxelCoord memory spawnVoxelAtCoord = add(lowerSouthWestCorner, relativeCoord);

      require(
        spawnVoxelAtCoord.y >= CHUNK_MIN_Y && spawnVoxelAtCoord.y <= CHUNK_MAX_Y,
        string(
          abi.encodePacked("Cannot spawn voxel outside of chunk boundaries at y=", int32ToString(spawnVoxelAtCoord.y))
        )
      );

      bytes32[] memory entitiesAtPosition = getEntitiesAtCoord(spawnVoxelAtCoord);

      // delete the voxels at this coord
      IWorld(_world()).tenet_MineSystem_clearCoord(spawnVoxelAtCoord);

      // create the voxel at this coord
      bytes32 newEntity = getUniqueEntity();
      VoxelType.set(newEntity, voxelTypes[i]);
      Position.set(newEntity, spawnVoxelAtCoord.x, spawnVoxelAtCoord.y, spawnVoxelAtCoord.z);

      enterVoxelIntoWorld(_world(), newEntity);
      updateVoxelVariant(_world(), newEntity);
      increaseVoxelTypeSpawnCount(voxelTypes[i].voxelTypeNamespace, voxelTypes[i].voxelTypeId);
      IWorld(_world()).tenet_VoxInteractSys_runInteractionSystems(newEntity);

      // update the spawn-related components
      OfSpawn.set(newEntity, spawnId);
      spawnVoxels[i] = newEntity;
    }

    spawnData.voxels = spawnVoxels;
    Spawn.set(spawnId, spawnData);

    increaseCreationSpawnCount(creationId);

    return spawnId;
  }

  function getAllVoxels(bytes32 creationId) private view returns (VoxelTypeData[] memory, VoxelCoord[] memory) {
    CreationData memory creation = Creation.get(creationId);
    VoxelTypeData[] memory voxelTypes = abi.decode(creation.voxelTypes, (VoxelTypeData[]));
    VoxelCoord[] memory relativeVoxelCoords = abi.decode(creation.relativePositions, (VoxelCoord[]));
    VoxelTypeData[] memory allVoxelTypes = new VoxelTypeData[](creation.numVoxels);
    VoxelCoord[] memory allRelativeCoords = new VoxelCoord[](creation.numVoxels);

    uint32 numNonBaseCreationVoxels = voxelTypes.length;
    for (uint i = 0; i < numNonBaseCreationVoxels; i++) {
      allVoxelTypes[i] = voxelTypes[i];
      allRelativeCoords[i] = relativeVoxelCoords[i];
    }
    uint32 voxelIdx = numNonBaseCreationVoxels;
    for (uint i = 0; i < creation.baseCreations.length; i++) {
      BaseCreation memory baseCreation = creation.baseCreations[i];
      (VoxelTypeData[] memory baseVoxelTypes, VoxelCoord[] memory baseRelativeCoords) = getBaseCreationVoxels(
        baseCreation
      );
      for (uint j = 0; j < baseVoxelTypes.length; j++) {
        allVoxelTypes[voxelIdx] = baseVoxelTypes[j];
        allRelativeCoords[voxelIdx] = baseRelativeCoords[j];
        voxelIdx++;
      }
    }
    return (allVoxelTypes, allRelativeCoords);
  }

  function getBaseCreationVoxels(
    BaseCreation memory baseCreation
  ) private view returns (VoxelTypeData[] memory, VoxelCoord[] memory) {
    CreationData memory creation = Creation.get(baseCreation.creationId);
    VoxelCoord[] memory relativeCoords = abi.decode(creation.relativePositions, (VoxelCoord[]));
    VoxelTypeData[] memory voxelTypes = abi.decode(creation.voxelTypes, (VoxelTypeData[]));

    // TODO: this doesn't factor in the base creation!
    uint256 numVoxels = voxelTypes.length - baseCreation.deletedRelativeCoords.length;
    VoxelTypeData[] memory newVoxelTypes = new VoxelTypeData[](numVoxels);
    VoxelCoord[] memory newRelativeCoords = new VoxelCoord[](numVoxels);

    // loop through all the voxels in the base creation and remove the deleted ones
    uint32 voxelIdx = 0;
    for (uint32 i = 0; i < numVoxels; i++) {
      VoxelCoord[] memory coord = relativeCoords[i];
      bool isDeleted = false;
      for (uint32 j = 0; j < baseCreation.deletedRelativeCoords.length; j++) {
        if (voxelCoordsAreEqual(coord, baseCreation.deletedRelativeCoords[j])) {
          isDeleted = true;
          break;
        }
      }
      if (!isDeleted) {
        newVoxelTypes[voxelIdx] = voxelTypes[i];
        newRelativeCoords[voxelIdx] = coord[i];
        voxelIdx++;
      }
    }

    return (newVoxelTypes, newRelativeCoords);
  }

  function increaseCreationSpawnCount(bytes32 creationId) private {
    CreationData memory creationData = Creation.get(creationId);
    creationData.numSpawns += 1;
    Creation.set(creationId, creationData);
  }
}
