// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { addressToEntityKey, getEntitiesAtCoord } from "../utils.sol";
import { OwnedBy, Position, Name, VoxelType, Description, VoxelTypes, Metadata, Positions } from "../codegen/Tables.sol";
import {PositionData} from "../codegen/tables/Position.sol";
import { VoxelCoord } from "../types.sol";
import { AirID } from "../prototypes/Voxels.sol";
//import { CreateBlock } from "../libraries/CreateBlock.sol";

uint256 constant MAX_BLOCKS_IN_CREATION = 100;

contract RegisterCreationSystem is System {
    function registerCreation(string memory name, string memory description, bytes32[] memory voxels) public returns (bytes32) { // returns the created creationId
        VoxelCoord[] memory voxelCoords = getVoxelCoords(voxels);
        validateCreation(voxelCoords);

        bytes32[] memory voxelTypes = getVoxelTypes(voxels);
        (int32[] memory repositionedX, int32[] memory repositionedY, int32[] memory repositionedZ) = repositionBlocksSoLowerSouthwestCornerIsOnOrigin(voxelCoords);

        bytes32 creationId = getCreationHash(voxels, _msgSender());

        Description.set(creationId, description);
        Name.set(creationId, name);
        OwnedBy.set(creationId, addressToEntityKey(_msgSender()));
        VoxelTypes.set(creationId, voxelTypes);
        Positions.set(creationId, repositionedX, repositionedY, repositionedZ);

        return creationId;
    }

    function validateCreation(VoxelCoord[] memory voxelCoords) private {
        require(
            voxelCoords.length <= MAX_BLOCKS_IN_CREATION,
            string(abi.encodePacked("Your creation cannot exceed ", Strings.toString(MAX_BLOCKS_IN_CREATION), " blocks"))
        );
        // TODO: specify which coords are duplicated
        require(!hasDuplicateVoxelCoords(voxelCoords), "Two voxels in your creation has the same coordinates");

        // TODO: should we also limit the dimensions of the creation?
    }

    // TODO: put this into a precompile for speed
    function repositionBlocksSoLowerSouthwestCornerIsOnOrigin(
        VoxelCoord[] memory voxelCoords
    ) private pure returns (int32[] memory, int32[] memory, int32[] memory) {
        int32 lowestX = 2147483647;
        int32 lowestY = 2147483647;
        int32 lowestZ = 2147483647;
        for (uint32 i = 0; i < voxelCoords.length; i++) {
            VoxelCoord memory voxel = voxelCoords[i];
            if (voxel.x < lowestX) {
                lowestX = voxel.x;
            }
            if (voxel.y < lowestY) {
                lowestY = voxel.y;
            }
            if (voxel.z < lowestZ) {
                lowestZ = voxel.z;
            }
        }

        int32[] memory repositionedX = new int32[](voxelCoords.length);
        int32[] memory repositionedY = new int32[](voxelCoords.length);
        int32[] memory repositionedZ = new int32[](voxelCoords.length);

        for (uint32 i = 0; i < voxelCoords.length; i++) {
            VoxelCoord memory voxel = voxelCoords[i];
            repositionedX[i] = voxel.x - lowestX;
            repositionedY[i] = voxel.y - lowestY;
            repositionedZ[i] = voxel.z - lowestZ;
        }
        return (repositionedX, repositionedY, repositionedZ);
    }

    function getVoxelTypes(bytes32[] memory voxels) private view returns ( bytes32[] memory) {
        bytes32[] memory voxelTypes = new bytes32[](voxels.length);
        for (uint32 i = 0; i < voxels.length; i++) {
            voxelTypes[i] = VoxelType.get(voxels[i]);
        }
        return voxelTypes;
    }

    function getVoxelCoords(bytes32[] memory voxels) private view returns ( VoxelCoord[] memory ) {
        VoxelCoord[] memory voxelCoords = new VoxelCoord[](voxels.length);
        for (uint32 i = 0; i < voxels.length; i++) {
            PositionData memory position = Position.get(voxels[i]);
            voxelCoords[i] = VoxelCoord(position.x, position.y, position.z);
        }
        return voxelCoords;
    }

    function hasDuplicateVoxelCoords(
        VoxelCoord[] memory coords
    ) private view returns (bool) {
        for (uint i = 0; i < coords.length; i++) {
            for (uint j = i+1; j < coords.length; j++) {
                if(coords[i].x == coords[j].x && coords[i].y == coords[j].y && coords[i].z == coords[j].z) {
                    return true;
                }
            }
        }
        return false;
    }

    // hashing the message sender means that two different players can register the same creation
    // I think it's fine, because two players can solve a level in the same way
    function getCreationHash(bytes32[] memory voxelIds, address sender) public pure returns (bytes32) {
        // TODO: entitiyIds change. should we use voxelType + coord + poweredComponent
        // TODO: have a global way for new systems and components to register a unique voxel name
        return bytes32(keccak256(abi.encode(voxelIds, sender)));
    }
}
