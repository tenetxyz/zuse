// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-contracts/src/Types.sol";
import { OwnedBy, Position, PositionTableId, VoxelType, VoxelTypeData, OfSpawn, Spawn, SpawnData } from "@tenet-contracts/src/codegen/Tables.sol";
import { increaseVoxelTypeSpawnCount } from "../Utils.sol";
import { voxelCoordsAreEqual, add } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { int32ToString } from "@tenet-utils/src/StringUtils.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { console } from "forge-std/console.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { CHUNK_MAX_Y, CHUNK_MIN_Y } from "../Constants.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { getVoxelsInCreation } from "@tenet-registry/src/Utils.sol";

contract SpawnSystem is System {
  function spawn(VoxelCoord memory lowerSouthWestCorner, bytes32 creationId) public returns (bytes32) {
    // 1) get all the voxels in the creation
    (VoxelCoord[] memory relativeVoxelCoords, VoxelTypeData[] memory voxelTypes) = getVoxelsInCreation(
      REGISTRY_ADDRESS,
      creationId
    );

    bytes32 spawnId = getUniqueEntity();
    VoxelEntity[] memory spawnVoxels = new VoxelEntity[](relativeVoxelCoords.length);

    // 2) create an instance of each voxel in the creation, put it into the world, and add it to the spawnVoxels array
    for (uint i = 0; i < relativeVoxelCoords.length; i++) {
      VoxelCoord memory relativeCoord = relativeVoxelCoords[i];
      VoxelCoord memory spawnVoxelAtCoord = add(lowerSouthWestCorner, relativeCoord);
      require(
        spawnVoxelAtCoord.y >= CHUNK_MIN_Y && spawnVoxelAtCoord.y <= CHUNK_MAX_Y,
        string(
          abi.encodePacked("Cannot spawn voxel outside of chunk boundaries at y=", int32ToString(spawnVoxelAtCoord.y))
        )
      );

      (uint32 scale, bytes32 newEntity) = IWorld(_world()).buildVoxelType(
        voxelTypes[i].voxelTypeId,
        spawnVoxelAtCoord,
        true,
        true
      );

      // update the spawn-related components
      OfSpawn.set(scale, newEntity, spawnId);
      spawnVoxels[i] = VoxelEntity({ scale: scale, entityId: newEntity });
    }

    // 3) Write the spawnData to the Spawn table
    SpawnData memory spawnData;
    spawnData.creationId = creationId;
    spawnData.lowerSouthWestCorner = abi.encode(lowerSouthWestCorner);
    spawnData.isModified = false;
    spawnData.voxels = abi.encode(spawnVoxels);
    Spawn.set(spawnId, spawnData);

    // 4) update spawn creation metrics
    increaseCreationSpawnCount(creationId);
    return spawnId;
  }

  function increaseCreationSpawnCount(bytes32 creationId) private {
    // CreationData memory creationData = Creation.get(creationId);
    // creationData.numSpawns += 1;
    // Creation.set(creationId, creationData);
  }
}
