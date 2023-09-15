// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { BuildEventData } from "@tenet-base-world/src/Types.sol";
import { OwnedBy, Position, PositionTableId, VoxelType, OfSpawn, Spawn, SpawnData } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelTypeData } from "@tenet-utils/src/Types.sol";
import { voxelCoordsAreEqual, add } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { int32ToString } from "@tenet-utils/src/StringUtils.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { console } from "forge-std/console.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { CHUNK_MAX_Y, CHUNK_MIN_Y } from "@tenet-world/src/Constants.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { getVoxelsInCreation, creationSpawned } from "@tenet-registry/src/Utils.sol";

contract SpawnSystem is System {
  function spawn(VoxelEntity agentEntity, VoxelCoord memory lowerSouthWestCorner, bytes32 creationId) public returns (bytes32) {
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

      VoxelEntity memory newEntity = IWorld(_world()).buildVoxelType(
        voxelTypes[i].voxelTypeId,
        spawnVoxelAtCoord,
        true,
        true,
        abi.encode(BuildEventData({ agentEntity: agentEntity, mindSelector: bytes4(0) })) /// TODO: which mind to use during spawns?
      );
      uint32 scale = newEntity.scale;
      bytes32 newEntityId = newEntity.entityId;

      // update the spawn-related components
      OfSpawn.set(scale, newEntityId, spawnId);
      spawnVoxels[i] = newEntity;
    }

    // 3) Write the spawnData to the Spawn table
    SpawnData memory spawnData;
    spawnData.creationId = creationId;
    spawnData.lowerSouthWestCorner = abi.encode(lowerSouthWestCorner);
    spawnData.isModified = false;
    spawnData.voxels = abi.encode(spawnVoxels);
    Spawn.set(spawnId, spawnData);

    // 4) update spawn creation metrics
    creationSpawned(REGISTRY_ADDRESS, creationId);

    return spawnId;
  }
}
