// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { addressToEntityKey, getEntitiesAtCoord } from "../utils.sol";
import { OwnedBy, Position, Name, Item, Voxels } from "../codegen/Tables.sol";
import { VoxelCoord } from "../types.sol";
import { AirID } from "../prototypes/Blocks.sol";
//import { CreateBlock } from "../libraries/CreateBlock.sol";

uint256 constant MAX_BLOCKS_IN_CREATION = 100;

contract RegisterCreationSystem is System {
    function registerCreation(string memory creationName, VoxelCoord memory corner1, VoxelCoord memory corner2) public returns (bytes32) { // returns the created creationId
        // calculate the corners here (to avoid stack too deep error)
        (VoxelCoord memory lowerSouthWestCorner, VoxelCoord memory upperNorthEastCorner) = getBoundingBox(corner1, corner2);
        (uint256 numVoxels, bytes32[] memory creationVoxelIds, VoxelCoord[] memory creationVoxelCoords) = getCreationVoxels(
            lowerSouthWestCorner,
            upperNorthEastCorner
        );

        require(
            numVoxels <= MAX_BLOCKS_IN_CREATION,
            string(abi.encodePacked("Your creation cannot exceed ", Strings.toString(MAX_BLOCKS_IN_CREATION), " blocks"))
        );

        bytes32 creationId = getCreationHash(creationVoxelIds, _msgSender());

        Name.set(creationId, creationName);
        OwnedBy.set(creationId, addressToEntityKey(msg.sender));

        // now we can safely make this new creation
        VoxelCoord[] memory repositionedCoords = repositionBlocksSoLowerSouthwestCornerIsOnOrigin(
            creationVoxelCoords,
            numVoxels
        );

        // TODO: properly clone the voxels. we need to emit a clone event
        for (uint32 i = 0; i < numVoxels; i++) {
            bytes32 newVoxel = getUniqueEntity();

            VoxelCoord memory repositionedCoord = repositionedCoords[i];
            Position.set(newVoxel, repositionedCoord.x, repositionedCoord.y, repositionedCoord.z);
            // TODO: this should be itemComponent
            bytes32 voxelType = Item.get(creationVoxelIds[i]);
            Item.set(newVoxel, voxelType);
            // TODO: we should init the default components for this voxel type
            // CreateBlock.addCustomComponents(components, blockType, newVoxel);

            Voxels.push(creationId, newVoxel);
        }

        return creationId;
    }

    function getCreationVoxels(
        VoxelCoord memory lowerSouthWestCorner,
        VoxelCoord memory upperNorthEastCorner
    )
    private view returns (
        uint256,
        bytes32[] memory,
        VoxelCoord[] memory
    )
    {
        uint32 numVoxelsInVolume = uint32(upperNorthEastCorner.x - lowerSouthWestCorner.x + 1) *
        uint32(upperNorthEastCorner.y - lowerSouthWestCorner.y + 1) *
        uint32(upperNorthEastCorner.z - lowerSouthWestCorner.z + 1);
        bytes32[] memory creationVoxelIds = new bytes32[](numVoxelsInVolume);
        VoxelCoord[] memory creationVoxelCoords = new VoxelCoord[](numVoxelsInVolume);
        uint32 numVoxels = 0;
        for (int32 x = lowerSouthWestCorner.x; x <= upperNorthEastCorner.x; x++) {
            for (int32 y = lowerSouthWestCorner.y; y <= upperNorthEastCorner.y; y++) {
                for (int32 z = lowerSouthWestCorner.z; z <= upperNorthEastCorner.z; z++) {
                    VoxelCoord memory coord = VoxelCoord(x, y, z);
                    bytes32[] memory entitiesAtCoord = getEntitiesAtCoord(coord);
                    if (entitiesAtCoord.length == 1) {
                        creationVoxelIds[numVoxels] = entitiesAtCoord[0];
                        creationVoxelCoords[numVoxels] = coord;
                        numVoxels++;
                    }
                }
            }
        }
        return (numVoxels, creationVoxelIds, creationVoxelCoords);
    }

    // TODO: put this into a precompile for speed
    function repositionBlocksSoLowerSouthwestCornerIsOnOrigin(VoxelCoord[] memory creationCoords, uint256 numVoxels)
    private
    pure
    returns (VoxelCoord[] memory)
    {
        int32 lowestX = 2147483647;
        int32 lowestY = 2147483647;
        int32 lowestZ = 2147483647;
        for (uint32 i = 0; i < numVoxels; i++) {
            VoxelCoord memory voxel = creationCoords[i];
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

        VoxelCoord[] memory repositionedCoords = new VoxelCoord[](numVoxels);
        for (uint32 i = 0; i < numVoxels; i++) {
            VoxelCoord memory voxel = creationCoords[i];
            VoxelCoord memory newRelativeCoord = VoxelCoord(voxel.x - lowestX, voxel.y - lowestY, voxel.z - lowestZ);
            repositionedCoords[i] = newRelativeCoord;
        }
        return repositionedCoords;
    }

    function getBoundingBox(VoxelCoord memory corner1, VoxelCoord memory corner2)
    private
    pure
    returns (VoxelCoord memory, VoxelCoord memory)
    {
        int32 lowerX = corner1.x < corner2.x ? corner1.x : corner2.x;
        int32 lowerY = corner1.y < corner2.y ? corner1.y : corner2.y;
        int32 lowerZ = corner1.z < corner2.z ? corner1.z : corner2.z;

        int32 upperX = corner1.x > corner2.x ? corner1.x : corner2.x;
        int32 upperY = corner1.y > corner2.y ? corner1.y : corner2.y;
        int32 upperZ = corner1.z > corner2.z ? corner1.z : corner2.z;

        return (VoxelCoord(lowerX, lowerY, lowerZ), VoxelCoord(upperX, upperY, upperZ));
    }

    // hashing the message sender means that two different players can register the same creation
    // I think it's fine, because two players can solve a level in the same way
    function getCreationHash(bytes32[] memory voxelIds, address sender) public pure returns (bytes32) {
        // TODO: entitiyIds change. should we use voxelType + coord + poweredComponent
        // TODO: have a global way for new systems and components to register a unique voxel name
        return bytes32(keccak256(abi.encode(voxelIds, sender)));
    }
}
