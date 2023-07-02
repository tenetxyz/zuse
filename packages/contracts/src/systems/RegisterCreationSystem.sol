// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { addressToEntityKey, getEntitiesAtCoord, voxelCoordToString } from "../Utils.sol";
import { VoxelType, Position, Creation, CreationData, VoxelTypeData } from "../codegen/Tables.sol";
import { PositionData } from "../codegen/tables/Position.sol";
import { VoxelCoord } from "../Types.sol";
import { AirID } from "../prototypes/Voxels.sol";
//import { CreateBlock } from "../libraries/CreateBlock.sol";

uint256 constant MAX_BLOCKS_IN_CREATION = 100;

contract RegisterCreationSystem is System {
  function registerCreation(
    string memory name,
    string memory description,
    bytes32[] memory voxels
  ) public returns (bytes32) {
    // returns the created creationId
    VoxelCoord[] memory voxelCoords = getVoxelCoords(voxels);
    validateCreation(voxelCoords);

    bytes memory voxelTypes = abi.encode(getVoxelTypes(voxels));
    bytes memory relativePositions = abi.encode(repositionBlocksSoLowerSouthwestCornerIsOnOrigin(voxelCoords));

    CreationData memory creation;
    creation.voxelTypes = voxelTypes;
    creation.creator = addressToEntityKey(_msgSender());
    creation.relativePositions = relativePositions;
    creation.name = name;
    creation.description = description;

    //        TODO: implement
    //        creation.voxelMetadata =

    bytes32 creationId = getCreationHash(voxelTypes, relativePositions, _msgSender());
    Creation.set(creationId, creation);
    return creationId;
  }

  function validateCreation(VoxelCoord[] memory voxelCoords) private {
    require(voxelCoords.length > 1, string(abi.encodePacked("Your creation must be at least 2 blocks")));
    require(
      voxelCoords.length <= MAX_BLOCKS_IN_CREATION,
      string(abi.encodePacked("Your creation cannot exceed ", Strings.toString(MAX_BLOCKS_IN_CREATION), " blocks"))
    );

    (bool hasDuplicate, VoxelCoord memory duplicate1, VoxelCoord memory duplicate2) = hasDuplicateVoxelCoords(
      voxelCoords
    );
    require(
      !hasDuplicate,
      string(
        abi.encodePacked("Two voxels in your creation have the same coordinates: ", voxelCoordToString(duplicate1))
      )
    );

    // TODO: should we also limit the dimensions of the creation?
  }

  // TODO: put this into a precompile for speed
  function repositionBlocksSoLowerSouthwestCornerIsOnOrigin(
    VoxelCoord[] memory voxelCoords
  ) private pure returns (VoxelCoord[] memory) {
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

    VoxelCoord[] memory repositionedVoxelCoords = new VoxelCoord[](voxelCoords.length);
    for (uint32 i = 0; i < voxelCoords.length; i++) {
      VoxelCoord memory voxel = voxelCoords[i];
      repositionedVoxelCoords[i] = VoxelCoord({ x: voxel.x - lowestX, y: voxel.y - lowestY, z: voxel.z - lowestZ });
    }
    return repositionedVoxelCoords;
  }

  function getVoxelTypes(bytes32[] memory voxels) public view returns (VoxelTypeData[] memory) {
    VoxelTypeData[] memory voxelTypeData = new VoxelTypeData[](voxels.length);
    for (uint32 i = 0; i < voxels.length; i++) {
      voxelTypeData[i] = VoxelType.get(voxels[i]);
    }
    return voxelTypeData;
  }

  function getVoxelCoords(bytes32[] memory voxels) private view returns (VoxelCoord[] memory) {
    VoxelCoord[] memory voxelCoords = new VoxelCoord[](voxels.length);
    for (uint32 i = 0; i < voxels.length; i++) {
      PositionData memory position = Position.get(voxels[i]);
      voxelCoords[i] = VoxelCoord(position.x, position.y, position.z);
    }
    return voxelCoords;
  }

  function hasDuplicateVoxelCoords(
    VoxelCoord[] memory coords
  ) private view returns (bool, VoxelCoord memory, VoxelCoord memory) {
    for (uint i = 0; i < coords.length; i++) {
      for (uint j = i + 1; j < coords.length; j++) {
        if (coords[i].x == coords[j].x && coords[i].y == coords[j].y && coords[i].z == coords[j].z) {
          return (true, coords[i], coords[j]);
        }
      }
    }
    VoxelCoord memory emptyCoord = VoxelCoord(0, 0, 0);
    return (false, emptyCoord, emptyCoord);
  }

  // hashing the message sender means that two different players can register the same creation
  // I think it's fine, because two players can solve a level in the same way
  function getCreationHash(
    bytes memory voxelTypes,
    bytes memory relativePositions,
    address sender
  ) public pure returns (bytes32) {
    return bytes32(keccak256(abi.encode(voxelTypes, relativePositions, sender)));
  }
}
