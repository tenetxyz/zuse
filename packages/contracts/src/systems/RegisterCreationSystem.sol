// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { addressToEntityKey, getEntitiesAtCoord, voxelCoordToString, voxelCoordsAreEqual, add, sub } from "../Utils.sol";
import { VoxelType, Position, Creation, CreationData, VoxelTypeData, Spawn, SpawnData, OfSpawn } from "@tenet-contracts/src/codegen/Tables.sol";
import { PositionData } from "@tenet-contracts/src/codegen/tables/Position.sol";
import { VoxelCoord, BaseCreation, BaseCreationInWorld } from "@tenet-contracts/src/Types.sol";
//import { CreateBlock } from "../libraries/CreateBlock.sol";

uint256 constant MAX_BLOCKS_IN_CREATION = 100;

contract RegisterCreationSystem is System {
  // returns the created creationId
  function registerCreation(
    string memory name,
    string memory description,
    bytes32[] memory voxels,
    bytes memory encodedBaseCreationsInWorld
  ) public returns (bytes32) {
    VoxelCoord[] memory voxelCoords = getVoxelCoords(voxels);
    VoxelTypeData[] memory voxelTypes = getVoxelTypes(voxels);

    BaseCreationInWorld[] memory baseCreationsInWorld = abi.decode(
      encodedBaseCreationsInWorld,
      (BaseCreationInWorld[])
    );
    (VoxelCoord[] memory allVoxelCoords, VoxelTypeData[] memory allVoxelTypes) = getVoxels(
      voxelCoords, // NOTE: we do not know the relative position of these voxelCoords yet (since we don't know the coords of the voxels in the base creations). So we will reposition them later
      voxelTypes,
      baseCreationsInWorld
    );
    // NOTE: all the coords are relative to the WORLD right now, not to the lower left corner of the creation
    validateCreation(allVoxelCoords);

    VoxelCoord memory lowerSouthwestCorner = getLowerSouthwestCorner(voxelCoords);
    VoxelCoord[] memory relativePositions = repositionBlocksSoLowerSouthwestCornerIsOnOrigin(
      voxelCoords, // Now that we know the coords of all the voxels, we can FINALLY reposition them
      lowerSouthwestCorner
    );

    BaseCreation[] memory baseCreations = convertBaseCreationsInWorldToBaseCreation(
      baseCreationsInWorld,
      lowerSouthwestCorner
    );

    CreationData memory creation;
    creation.creator = tx.origin;
    creation.numVoxels = uint32(allVoxelCoords.length);
    creation.voxelTypes = abi.encode(voxelTypes);
    creation.relativePositions = abi.encode(relativePositions);
    creation.name = name;
    creation.description = description;
    creation.baseCreations = abi.encode(baseCreations);

    bytes32 creationId = getCreationHash(allVoxelTypes, relativePositions, _msgSender());
    // TODO: verify that this creationId doesn't already exist
    Creation.set(creationId, creation);
    // IWorld(_world()).tenet_SpawnSystem_spawn(lowerSouthWestCorner, creationId); // make this creation a spawn
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

  function getLowerSouthwestCorner(VoxelCoord[] memory voxelCoords) private pure returns (VoxelCoord memory) {
    int32 lowestX = 2147483647; // TODO: use type(int32).max;
    int32 lowestY = 2147483647;
    int32 lowestZ = 2147483647;
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
    return VoxelCoord({ x: lowestX, y: lowestY, z: lowestZ });
  }

  // PERF: put this into a precompile for speed
  function repositionBlocksSoLowerSouthwestCornerIsOnOrigin(
    VoxelCoord[] memory voxelCoords,
    VoxelCoord memory lowerSouthwestCorner
  ) private pure returns (VoxelCoord[] memory) {
    VoxelCoord[] memory repositionedVoxelCoords = new VoxelCoord[](voxelCoords.length);
    for (uint32 i = 0; i < voxelCoords.length; i++) {
      VoxelCoord memory voxel = voxelCoords[i];
      repositionedVoxelCoords[i] = VoxelCoord({
        x: voxel.x - lowerSouthwestCorner.x,
        y: voxel.y - lowerSouthwestCorner.y,
        z: voxel.z - lowerSouthwestCorner.z
      });
    }
    return (repositionedVoxelCoords);
  }

  // Why not merge this function with getVoxelsInCreation? It's because the coords that are returned by the voxels in a registered creation
  // are RELATIVE to the lowerSouthWestCorner of the creation. But right now, we do NOT know what the lowerSouthWestCorner is, we only know
  // where all the baseCreationsInWorld are in the world.
  function getVoxels(
    VoxelCoord[] memory rootVoxelCoords,
    VoxelTypeData[] memory rootVoxelTypes,
    BaseCreationInWorld[] memory baseCreationsInWorld
  ) public view returns (VoxelCoord[] memory, VoxelTypeData[] memory) {
    uint32 numVoxels = calculateNumVoxelsInComposedCreation(baseCreationsInWorld, rootVoxelTypes.length);

    VoxelCoord[] memory allVoxelCoords = new VoxelCoord[](numVoxels); // these are the coords of the voxel in the world. they are NOT relative
    VoxelTypeData[] memory allVoxelTypes = new VoxelTypeData[](numVoxels);

    // 1) add all the (non-base) voxels in this creation to the arrays
    for (uint32 i = 0; i < rootVoxelCoords.length; i++) {
      allVoxelCoords[i] = rootVoxelCoords[i];
      allVoxelTypes[i] = rootVoxelTypes[i];
    }

    uint32 voxelIdx = uint32(rootVoxelCoords.length);

    for (uint32 i = 0; i < baseCreationsInWorld.length; i++) {
      BaseCreationInWorld memory baseCreationInWorld = baseCreationsInWorld[i];
      (VoxelCoord[] memory baseVoxelCoords, VoxelTypeData[] memory baseVoxelTypes) = getVoxelsInCreation(
        baseCreationInWorld.creationId
      );

      uint32 numDeleted = 0;
      // now we need to remove the voxels that were deleted in the base creation
      for (uint32 j = 0; j < baseVoxelCoords.length; j++) {
        VoxelCoord memory baseVoxelCoord = baseVoxelCoords[j];
        bool isDeleted = false;
        for (uint32 k = 0; k < baseCreationInWorld.deletedRelativeCoords.length; k++) {
          VoxelCoord memory deletedRelativeCoord = baseCreationInWorld.deletedRelativeCoords[k];
          if (voxelCoordsAreEqual(baseVoxelCoord, deletedRelativeCoord)) {
            // this voxel is deleted, so don't add it
            isDeleted = true;
            break;
          }
        }
        if (!isDeleted) {
          allVoxelCoords[voxelIdx] = add(baseCreationInWorld.lowerSouthWestCornerInWorld, baseVoxelCoord);
          allVoxelTypes[voxelIdx] = baseVoxelTypes[j];
          voxelIdx++;
        }
      }

      require(
        numDeleted == baseCreationInWorld.deletedRelativeCoords.length,
        string(
          abi.encode(
            "you deleted voxels in baseCreationInWorld.creationId: ",
            baseCreationInWorld.creationId,
            " that don't exist in the creation"
          )
        )
      );
    }
  }

  function calculateNumVoxelsInComposedCreation(
    BaseCreationInWorld[] memory baseCreationsInWorld,
    uint256 rootVoxelTypesLength
  ) internal view returns (uint32) {
    uint32 numVoxels = uint32(rootVoxelTypesLength);
    for (uint32 i = 0; i < baseCreationsInWorld.length; i++) {
      BaseCreationInWorld memory baseCreation = baseCreationsInWorld[i];
      uint256 numVoxelsInBaseCreation = Creation.getNumVoxels(baseCreation.creationId);
      uint256 numDeleteVoxels = baseCreation.deletedRelativeCoords.length;
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

      numVoxels += uint32(numVoxelsInBaseCreation - numDeleteVoxels);
    }
    return numVoxels;
  }

  // we need to find out which voxels are not deleted
  // so we just need to compile a list of all the voxels in the base creations
  // then we need to remove the voxels that are deleted

  function getVoxelsInCreation(bytes32 creationId) public view returns (VoxelCoord[] memory, VoxelTypeData[] memory) {
    CreationData memory creation = Creation.get(creationId);
    VoxelCoord[] memory relativeCoords = new VoxelCoord[](creation.numVoxels);
    VoxelTypeData[] memory voxelTypes = new VoxelTypeData[](creation.numVoxels);

    VoxelCoord[] memory creationRelativeCoords = abi.decode(creation.relativePositions, (VoxelCoord[]));
    VoxelTypeData[] memory creationVoxelTypes = abi.decode(creation.voxelTypes, (VoxelTypeData[]));

    // 1) add all the (non-base) voxels in this creation to the arrays
    for (uint32 i = 0; i < creationRelativeCoords.length; i++) {
      relativeCoords[i] = creationRelativeCoords[i];
      voxelTypes[i] = creationVoxelTypes[i];
    }
    uint32 voxelIdx = uint32(creationRelativeCoords.length);

    // 2) for each child base creation, add all of its voxels (and its coords) to our voxels array (minus the deleted voxels)
    BaseCreation[] memory baseCreations = abi.decode(creation.baseCreations, (BaseCreation[]));

    for (uint32 i = 0; i < creation.baseCreations.length; i++) {
      BaseCreation memory baseCreation = baseCreations[i];
      CreationData memory childCreation = Creation.get(baseCreation.creationId);

      (VoxelCoord[] memory childVoxelCoords, VoxelTypeData[] memory childVoxelTypes) = getVoxelsInCreation(
        baseCreation.creationId
      );

      // add each child voxel into our array (if it's not deleted)
      for (uint32 j = 0; j < childVoxelCoords.length; j++) {
        VoxelCoord memory childVoxelCoord = childVoxelCoords[j];
        bool isDeleted = false;
        for (uint32 k = 0; k < baseCreation.deletedRelativeCoords.length; k++) {
          VoxelCoord memory deletedRelativeCoord = baseCreation.deletedRelativeCoords[k];
          if (voxelCoordsAreEqual(childVoxelCoord, deletedRelativeCoord)) {
            // this voxel is deleted, so don't add it
            isDeleted = true;
            break;
          }
        }
        if (!isDeleted) {
          relativeCoords[voxelIdx] = add(baseCreation.coordOffset, childVoxelCoords[j]);
          voxelTypes[voxelIdx] = childVoxelTypes[j];
          voxelIdx++;
        }
      }
    }
    return (relativeCoords, voxelTypes);
  }

  function requireDeletedCoordsAreInBaseCreation(
    VoxelCoord[] memory creationRelativeCoords,
    VoxelCoord[] memory deletedRelativeCoords
  ) private pure {
    for (uint32 i = 0; i < deletedRelativeCoords.length; i++) {
      VoxelCoord memory deletedRelativeCoord = deletedRelativeCoords[i];
      bool deletedCoordExistsInCreation = false;
      for (uint32 j = 0; j < creationRelativeCoords.length; j++) {
        if (voxelCoordsAreEqual(deletedRelativeCoord, creationRelativeCoords[j])) {
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

  function convertBaseCreationsInWorldToBaseCreation(
    BaseCreationInWorld[] memory baseCreationsInWorld,
    VoxelCoord memory lowerSouthwestCorner
  ) private pure returns (BaseCreation[] memory) {
    BaseCreation[] memory baseCreations = new BaseCreation[](baseCreationsInWorld.length);
    for (uint32 i = 0; i < baseCreationsInWorld.length; i++) {
      baseCreations[i] = BaseCreation({
        creationId: baseCreationsInWorld[i].creationId,
        coordOffset: sub(baseCreationsInWorld[i].lowerSouthWestCornerInWorld, lowerSouthwestCorner),
        deletedRelativeCoords: baseCreationsInWorld[i].deletedRelativeCoords
      });
    }
    return baseCreations;
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
    VoxelTypeData[] memory voxelTypes,
    VoxelCoord[] memory relativePositions,
    address sender
  ) public pure returns (bytes32) {
    return bytes32(keccak256(abi.encode(voxelTypes, relativePositions, sender)));
  }
}
