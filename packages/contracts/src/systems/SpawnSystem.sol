// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../types.sol";
import { OwnedBy, Position, PositionTableId, VoxelType, RelativePositions, OfSpawn, Spawn, SpawnData, Creation } from "../codegen/Tables.sol";
import { getEntitiesAtCoord, add, int32ToString } from "../utils.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { console } from "forge-std/console.sol";
import {RelativePositionsData} from "../codegen/tables/RelativePositions.sol";
import { CHUNK_MAX_Y, CHUNK_MIN_Y } from "../Constants.sol";

contract SpawnSystem is System {

    function spawn(VoxelCoord memory lowerSouthWestCorner, bytes32 creationId) public returns (bytes32) {
        // relPosX = all the relative position X coordinates
        Creation memory creation = Creation.get(creationId);
        RelativePositionsData memory relativePositions = RelativePositions.get(creationId);
        int32[] memory relPosX = relativePositions.x;
        int32[] memory relPosY = relativePositions.y;
        int32[] memory relPosZ = relativePositions.z;

        SpawnData memory spawnData;
        bytes32[] memory spawnVoxels = new bytes32[](voxelTypes.length);
        spawnData.creationId = creationId;
        spawnData.lowerSouthWestCornerX = lowerSouthWestCorner.x;
        spawnData.lowerSouthWestCornerY = lowerSouthWestCorner.y;
        spawnData.lowerSouthWestCornerZ = lowerSouthWestCorner.z;

        bytes32 spawnId = getUniqueEntity();
        for(uint i = 0; i < voxelTypes.length; i++){
            VoxelCoord memory relativeCoord = VoxelCoord(relPosX[i], relPosY[i], relPosZ[i]);
            VoxelCoord memory spawnVoxelAtCoord = add(lowerSouthWestCorner, relativeCoord);

            require(
                spawnVoxelAtCoord.y >= CHUNK_MIN_Y && spawnVoxelAtCoord.y <= CHUNK_MAX_Y,
                string(abi.encodePacked(
                    "Cannot spawn voxel outside of chunk boundaries at y=",
                    int32ToString(spawnVoxelAtCoord.y)
                ))
            );

            bytes32[] memory entitiesAtPosition = getEntitiesAtCoord(spawnVoxelAtCoord);

            // delete the voxels at this coord
            for(uint j = 0; j < entitiesAtPosition.length; j++){
                // this is kinda sus rn, cause we aren't clearing all the extra components
                // we'll do this later once voxel spawning is finished

                bytes32 entity = entitiesAtPosition[j];
                Position.deleteRecord(entity);
                VoxelType.deleteRecord(entity);
            }

            // create the voxel at this coord
            bytes32 newEntity = getUniqueEntity();
            VoxelType.set(newEntity, voxelTypes[i]);
            Position.set(newEntity, spawnVoxelAtCoord.x, spawnVoxelAtCoord.y, spawnVoxelAtCoord.z);

            // update the spawn-related components
            OfSpawn.set(newEntity, spawnId);
            spawnVoxels[i] = newEntity;
        }

        spawnData.voxels = spawnVoxels;
        Spawn.set(spawnId, spawnData);


        // should we run this?
//        IWorld(_world()).tenet_VoxelInteraction_runInteractionSystems(airEntity);
        return spawnId;
    }
}