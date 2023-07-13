// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { addressToEntityKey, getEntitiesAtCoord, voxelCoordToString } from "../Utils.sol";
import { VoxelType, Position, Creation, CreationData, VoxelTypeData, Spawn, SpawnData, OfSpawn } from "@tenet-contracts/src/codegen/Tables.sol";
import { PositionData } from "@tenet-contracts/src/codegen/tables/Position.sol";
import { VoxelCoord, BaseCreation } from "../Types.sol";
//import { CreateBlock } from "../libraries/CreateBlock.sol";

uint256 constant MAX_BLOCKS_IN_CREATION = 100;

contract RegisterCreationSystem is System {
  function registerCreation(
    string memory name,
    string memory description,
    bytes32[] memory voxels,
    bytes memory baseCreations
  ) public returns (bytes32) {
    // returns the created creationId
    VoxelCoord[] memory voxelCoords = getVoxelCoords(voxels);
    validateCreation(voxelCoords);

    bytes memory voxelTypes = abi.encode(getVoxelTypes(voxels));
    (
      bytes memory relativePositions,
      VoxelCoord memory lowerSouthWestCorner
    ) = repositionBlocksSoLowerSouthwestCornerIsOnOrigin(voxelCoords, baseCreations);

    CreationData memory creation;
    creation.voxelTypes = voxelTypes;
    creation.creator = tx.origin;
    creation.relativePositions = relativePositions;
    creation.name = name;
    creation.description = description;
    creation.baseCreations = baseCreations;

    // TODO: implement
    // creation.voxelMetadata =

    bytes32 creationId = getCreationHash(voxelTypes, relativePositions, _msgSender());
    Creation.set(creationId, creation);
    registerVoxelsAsSpawn(creationId, lowerSouthWestCorner, voxels);
    return creationId;
  }

  function registerVoxelsAsSpawn(
    bytes32 creationId,
    VoxelCoord memory lowerSouthWestCorner,
    bytes32[] memory voxels
  ) private {
    bytes32 spawnId = getUniqueEntity();
    for (uint i = 0; i < voxels.length; i++) {
      OfSpawn.set(voxels[i], spawnId);
    }
    Spawn.set(spawnId, creationId, false, abi.encode(lowerSouthWestCorner), voxels);
  }

  function validateCreation(VoxelCoord[] memory voxelCoords) private pure {
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
        abi.encodePacked(
          "Two voxels in your creation have the same coordinates: ",
          voxelCoordToString(duplicate1),
          " and ",
          voxelCoordToString(duplicate2)
        )
      )
    );

    // TODO: should we also limit the dimensions of the creation?
  }

  // PERF: put this into a precompile for speed
  function repositionBlocksSoLowerSouthwestCornerIsOnOrigin(
    VoxelCoord[] memory voxelCoords,
    bytes memory baseCreations
  ) private pure returns (bytes memory, VoxelCoord memory) {
    int32 lowestX = 2147483647; // TODO: use type(int32).max;
    int32 lowestY = 2147483647;
    int32 lowestZ = 2147483647;
    (lowestX, lowestY, lowestZ) = getLowestCoord(voxelCoords, lowestX, lowestY, lowestZ);

    VoxelCoord[] memory baseCreationVoxelCoords = getVoxelCoordsFromBaseCreations(baseCreations);
    (lowestX, lowestY, lowestZ) = getLowestCoord(baseCreationVoxelCoords, lowestX, lowestY, lowestZ);

    VoxelCoord[] memory repositionedVoxelCoords = new VoxelCoord[](voxelCoords.length);
    for (uint32 i = 0; i < voxelCoords.length; i++) {
      VoxelCoord memory voxel = voxelCoords[i];
      repositionedVoxelCoords[i] = VoxelCoord({ x: voxel.x - lowestX, y: voxel.y - lowestY, z: voxel.z - lowestZ });
    }
    VoxelCoord memory lowerSouthWestCorner = VoxelCoord({ x: lowestX, y: lowestY, z: lowestZ });
    return (abi.encode(repositionedVoxelCoords), lowerSouthWestCorner);
  }

  function getLowestCoord(
    VoxelCoord[] memory voxelCoords,
    int32 lowestX,
    int32 lowestY,
    int32 lowestZ
  ) private pure returns (int32, int32, int32) {
    for (uint32 i = 0; i < voxelCoords.length; i++) {
      VoxelCoord memory voxelCoord = voxelCoords[i];
      if (voxelCoord.x < lowestX) {
        lowestX = voxelCoord.x;
      }
      if (voxelCoord.y < lowestY) {
        lowestY = voxelCoord.y;
      }
      if (voxelCoord.z < lowestZ) {
        lowestZ = voxelCoord.z;
      }
    }
    return (lowestX, lowestY, lowestZ);
  }

  function getVoxelCoordsFromBaseCreations(
    BaseCreation[] memory baseCreations
  ) private pure returns (VoxelCoord[] memory) {
    uint32 totalVoxels = calculateTotalVoxelsInComposedCreation(baseCreations);
    uint voxelIdx = 0;

    VoxelCoord[] memory voxelCoords = new VoxelCoord[](totalVoxels);
    for (uint32 i = 0; i < baseCreations.length; i++) {
      BaseCreation memory baseCreation = baseCreations[i];

      VoxelCoord[] memory creationRelativeCoords = abi.decode(
        Creation.getVoxelCoords(baseCreation.creationId),
        (VoxelCoord[])
      );
      VoxelCoord[] memory deletedRelativeCoords = baseCreation.deletedRelativeCoords;

      for (uint32 j = 0; j < creationRelativeCoords.length; j++) {
        VoxelCoord memory relativeCoord = creationRelativeCoords[j];
        // TODO: we need to figure out a way to have in-memory sets in solidity.
        bool isDeleted = false;
        for (uint32 k = 0; k < deletedCoords.length; k++) {
          if (deletedCoords[k] == relativeCoord) {
            isDeleted = true;
            break;
          }
        }
        if (!isDeleted) {
          voxelCoords[voxelIdx] = relativeCoord;
          voxelIdx++;
        }
      }
    }
    return voxelCoords;
  }

  function calculateTotalVoxelsInComposedCreation(BaseCreation[] memory baseCreations) private returns (uint32) {
    uint32 totalVoxels = 0;
    for (uint32 i = 0; i < baseCreations.length; i++) {
      VoxelCoord[] memory creationRelativeCoords = abi.decode(
        Creation.getVoxelCoords(baseCreation.creationId),
        (VoxelCoord[])
      );
      VoxelCoord[] memory deletedCoords = baseCreations[i].deletedCoords;
      verifyDeletedCoordsAreInBaseCreation(creationRelativeCoords, deletedCoords);

      totalVoxels += creationRelativeCoords.length - deletedCoords.length;
    }
    return totalVoxels;
  }

  function verifyDeletedCoordsAreInBaseCreation(
    VoxelCoord[] memory creationRelativeCoords,
    VoxelCoord[] memory deletedRelativeCoords
  ) private pure {
    for (uint32 i = 0; i < deletedRelativeCoords.length; i++) {
      bool deletedCoordExistsInCreation = false;
      for (uint32 j = 0; j < creationRelativeCoords.length; j++) {
        if (deletedRelativeCoords[i] == creationRelativeCoords[j]) {
          deletedCoordExistsInCreation = true;
          break;
        }
      }
      require(
        deletedCoordExistsInCreation,
        string(
          abi.encode(
            "This deleted coord does not exist in its base creation: ",
            voxelCoordToString(deletedRelativeCoords[i])
          )
        )
      );
    }
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
  ) private pure returns (bool, VoxelCoord memory, VoxelCoord memory) {
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
