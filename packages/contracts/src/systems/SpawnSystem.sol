// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../types.sol";
import { OwnedBy, Position, PositionTableId, VoxelType, Extension, ExtensionTableId, RelativePositions, VoxelTypes } from "../codegen/Tables.sol";
import { AirID, WaterID } from "../prototypes/Voxels.sol";
import { addressToEntityKey, getEntitiesAtCoord, add } from "../utils.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { Occurrence } from "../codegen/Tables.sol";
import { console } from "forge-std/console.sol";
import {RelativePositionsData} from "../codegen/tables/RelativePositions.sol";

contract SpawnSystem is System {

    function spawn(VoxelCoord memory lowerSouthWestCorner, bytes32 creationId) public returns (bytes32) {

        require(lowerSouthWestCorner.y >= -63, "out of chunk bounds");
        // TODO: check that the top of the creation doesn't exceed chunk bounds

        // relPosX = all the relative position X coordinates
        (bytes32[] memory voxelTypes) = VoxelTypes.get(creationId);
        RelativePositionsData memory relativePositions = RelativePositions.get(creationId);
        int32[] memory relPosX = relativePositions.x;
        int32[] memory relPosY = relativePositions.y;
        int32[] memory relPosZ = relativePositions.z;

        for(uint i = 0; i < voxelTypes.length; i++){
            VoxelCoord memory relativeCoord = VoxelCoord(relPosX[i], relPosY[i], relPosZ[i]);
            VoxelCoord memory spawnVoxelAtCoord = add(lowerSouthWestCorner, relativeCoord);
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
        }


        // should we run this?
//        IWorld(_world()).tenet_VoxelInteraction_runInteractionSystems(airEntity);
    }
}