// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { addressToEntityKey, getEntitiesAtCoord, voxelCoordToString, voxelCoordsAreEqual } from "../Utils.sol";
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
    bytes memory encodedBaseCreations
  ) public returns (bytes32) {
    // returns the created creationId
    VoxelCoord[] memory voxelCoords = getVoxelCoords(voxels);
    validateCreation(voxelCoords);

    BaseCreation[] memory baseCreations = abi.decode(encodedBaseCreations, (BaseCreation[]));
    VoxelCoord[] memory baseCreationVoxelCoords = getVoxelCoordsFromBaseCreations(baseCreations);

    bytes memory voxelTypes = abi.encode(getVoxelTypes(voxels));
    (
      bytes memory relativePositions,
      VoxelCoord memory lowerSouthWestCorner
    ) = repositionBlocksSoLowerSouthwestCornerIsOnOrigin(voxelCoords, baseCreationVoxelCoords);

    CreationData memory creation;
    creation.voxelTypes = voxelTypes;
    creation.creator = tx.origin;
    creation.numVoxels = voxelCoords.length + baseCreationVoxelCoords.length;
    creation.relativePositions = relativePositions;
    creation.name = name;
    creation.description = description;
    creation.baseCreations = baseCreations;

    bytes32 creationId = getCreationHash(voxelTypes, relativePositions, _msgSender());
    Creation.set(creationId, creation);
    IWorld(_world()).tenet_SpawnSystem_spawn(lowerSouthWestCorner, creationId); // make this creation a spawn
    return creationId;
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
    VoxelCoord[] memory baseCreationVoxelCoords
  ) private view returns (bytes memory, VoxelCoord memory) {
    int32 lowestX = 2147483647; // TODO: use type(int32).max;
    int32 lowestY = 2147483647;
    int32 lowestZ = 2147483647;
    (lowestX, lowestY, lowestZ) = getLowestCoord(voxelCoords, lowestX, lowestY, lowestZ);
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

  function getVoxels(
    VoxelCoord[] memory rootVoxelCoords,
    VoxelTypeData[] memory rootVoxelTypes,
    BaseCreation[] memory baseCreations
  ) view returns (VoxelCoord[] memory, VoxelTypeData[] memory) {
    CreationData memory baseCreation = Creation.get(baseCreations.creationId);
    VoxelCoord[] memory deletedRelativeCoords = baseCreation.deletedRelativeCoords;
    uint256 numVoxels = calculateNumVoxelsInComposedCreation(baseCreations);
    return getVoxelsInBaseCreations(rootVoxelCoords, rootVoxelTypes, baseCreations, numVoxels);
  }

  function calculateNumVoxelsInComposedCreation(BaseCreation[] memory baseCreations) private view returns (uint256) {
    uint256 numVoxels = 0;
    for (uint32 i = 0; i < baseCreations.length; i++) {
      uint256 numVoxelsInBaseCreation = Creation.getNumVoxels(baseCreations.creationId);
      uint256 numDeleteVoxels = baseCreations.deletedRelativeCoords.length;
      require(
        numVoxelsInBaseCreation > numDeleteVoxels,
        string(
          abi.encode(
            "You cannot delete ",
            Strings.toString(uint256(numDeleteVoxels)),
            " voxels, when the base creation has ",
            Strings.toString(uint256(numVoxelsInBaseCreation)),
            " voxels"
          )
        )
      );

      numVoxels += numVoxelsInBaseCreation - numDeleteVoxels;
    }
    return numVoxels;
  }

  // we need to find out which voxels are not deleted
  // so we just need to compile a list of all the voxels in the base creations
  // then we need to remove the voxels that are deleted

  // why pass all these in when we could've just gotten them from the creationId?
  // it's to help us do recurson easier (cuase for the current creation, we do NOT have a creationId. only the baseCreations have an ID)
  function getVoxelsInBaseCreations(
    VoxelCoord[] memory rootVoxelCoords,
    VoxelTypeData[] memory rootVoxelTypes,
    BaseCreation[] memory baseCreations,
    VoxelCoord[] memory deletedRelativeCoords,
    bytes32 numVoxels
  ) view returns (VoxelCoord[] memory, VoxelTypeData[] memory) {
    uint32 numDeletedVoxels = deletedRelativeCoords.length;
    uint32 numTotalVoxels = numVoxels - numDeletedVoxels; // the actual voxels for using this base creation

    // first add all the (non-base) voxels in this creation to the arrays
    VoxelCoord[] memory voxelCoords = new VoxelCoord[](numTotalVoxels);
    VoxelTypeData[] memory voxelTypes = new VoxelTypeData[](numTotalVoxels);
    for (uint32 i = 0; i < creation.voxels; i++) {
      voxelCoords[i] = rootVoxelTypes[i];
      voxelTypes[i] = rootVoxelTypes[i];
    }
    uint32 voxelIdx = creation.voxels.length;

    for (uint32 i = 0; i < baseCreationChildren.length; i++) {
      BaseCreation memory childBaseCreation = baseCreationChildren[i];

      CreationData memory childCreation = Creation.get(childBaseCreation.creationId);
      BaseCreation[] memory childBaseCreations = abi.decode(baseCreation, (BaseCreation[]));

      (VoxelCoord[] memory childVoxelCoords, VoxelTypeData[] memory childVoxelTypes) = getVoxelsInBaseCreations(
        childBaseCreations,
        childBaseCreation.deletedRelativeCoords,
        childCreation.numVoxels
      );

      for (uint32 j = 0; j < childVoxelCoords.length; j++) {
        VoxelCoord memory childVoxelCoord = childVoxelCoords[j];
        bool isDeleted = false;
        for (uint32 k = 0; k < deletedRelativeCoords.length; k++) {
          VoxelCoord memory deletedRelativeCoord = deletedRelativeCoords[k];
          if (voxelCoordsAreEqual(childVoxelCoord, deletedRelativeCoord)) {
            // this voxel is deleted, so don't add it
            isDeleted = true;
            break;
          }
        }
        if (!isDeleted) {
          voxelCoords[voxelIdx] = childVoxelCoords[voxelIdx];
          voxelTypes[voxelIdx] = childVoxelTypes[voxelIdx];
          voxelIdx++;
        }
      }
    }
    return (voxelCoords, voxelTypes);
  }

  function verifyDeletedCoordsAreInBaseCreation(
    VoxelCoord[] memory creationRelativeCoords,
    VoxelCoord[] memory deletedRelativeCoords
  ) private pure {
    for (uint32 i = 0; i < deletedRelativeCoords.length; i++) {
      bool deletedCoordExistsInCreation = false;
      for (uint32 j = 0; j < creationRelativeCoords.length; j++) {
        if (voxelCoordsAreEqual(deletedRelativeCoords[i], creationRelativeCoords[j])) {
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
