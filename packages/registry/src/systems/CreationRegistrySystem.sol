// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { voxelCoordToString, voxelCoordsAreEqual, add, sub } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { CreationRegistryTableId, CreationRegistry, CreationRegistryData, VoxelTypeRegistryTableId, VoxelTypeRegistry, VoxelVariantsRegistryTableId, VoxelVariantsRegistry } from "@tenet-registry/src/codegen/Tables.sol";
import { VoxelCoord, BaseCreation, BaseCreationInWorld, VoxelTypeData } from "@tenet-utils/src/Types.sol";

uint256 constant MAX_BLOCKS_IN_CREATION = 100;

contract CreationRegistrySystem is System {
  function registerCreation(
    string memory name,
    string memory description,
    VoxelTypeData[] memory voxelTypes,
    VoxelCoord[] memory voxelCoords,
    BaseCreationInWorld[] memory baseCreationsInWorld
  ) public returns (bytes32, VoxelCoord memory) {
    for (uint256 i = 0; i < voxelTypes.length; i++) {
      require(
        hasKey(VoxelTypeRegistryTableId, VoxelTypeRegistry.encodeKeyTuple(voxelTypes[i].voxelTypeId)),
        "Voxel type ID has not been registered"
      );
      require(
        hasKey(VoxelVariantsRegistryTableId, VoxelVariantsRegistry.encodeKeyTuple(voxelTypes[i].voxelVariantId)),
        "Voxel variant ID has not been registered"
      );
    }
    for (uint256 i = 0; i < baseCreationsInWorld.length; i++) {
      require(
        hasKey(CreationRegistryTableId, CreationRegistry.encodeKeyTuple(baseCreationsInWorld[i].creationId)),
        "Base creation ID has not been registered"
      );
    }

    // 1) get all of the voxelCoords of all voxels in the creation
    (VoxelCoord[] memory allVoxelCoordsInWorld, VoxelTypeData[] memory allVoxelTypes) = getVoxels(
      voxelCoords,
      voxelTypes,
      baseCreationsInWorld
    );

    // 2) validate the creation
    validateCreation(allVoxelCoordsInWorld);

    // 3) find the lowestSouthWestCorner so we can center the voxels about the origin (lowerSouthwestCorner)
    VoxelCoord memory lowerSouthwestCorner = getLowerSouthwestCorner(allVoxelCoordsInWorld);

    // 4) reposition the voxels so the lowerSouthwestCorner is on the origin
    // Note: we do NOT need to reposition the voxels within base creations because they are already positioned relative to the base creation
    VoxelCoord[] memory relativePositions = repositionBlocksSoLowerSouthwestCornerIsOnOrigin(
      voxelCoords,
      lowerSouthwestCorner
    );

    // 5) Reposition the base creations about the origin
    BaseCreation[] memory baseCreations = convertBaseCreationsInWorldToBaseCreation(
      baseCreationsInWorld,
      lowerSouthwestCorner
    );

    // 6) write all the fields of the creation to the table
    bytes32 creationId = getCreationHash(allVoxelTypes, relativePositions);
    require(
      !hasKey(CreationRegistryTableId, CreationRegistry.encodeKeyTuple(creationId)),
      "Creation has already been registered"
    );
    CreationRegistryData memory creationData;
    creationData.creator = tx.origin;
    creationData.numSpawns = 0;
    creationData.numVoxels = uint32(allVoxelCoordsInWorld.length);
    creationData.voxelTypes = abi.encode(allVoxelTypes);
    creationData.relativePositions = abi.encode(relativePositions);
    creationData.name = name;
    creationData.description = description;
    creationData.baseCreations = abi.encode(baseCreations);

    CreationRegistry.set(creationId, creationData);

    return (creationId, lowerSouthwestCorner);
  }

  function validateCreation(VoxelCoord[] memory voxelCoords) internal pure {
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

  function getLowerSouthwestCorner(VoxelCoord[] memory voxelCoords) internal pure returns (VoxelCoord memory) {
    int32 lowestX = type(int32).max;
    int32 lowestY = type(int32).max;
    int32 lowestZ = type(int32).max;
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
  ) internal pure returns (VoxelCoord[] memory) {
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
  ) internal view returns (VoxelCoord[] memory, VoxelTypeData[] memory) {
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
            numDeleted++;
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
            " that don't exist in the creation. Make sure that all baseCreationInWorld.deletedRelativeCoords are actually from the base creation"
          )
        )
      );
    }
    return (allVoxelCoords, allVoxelTypes);
  }

  function calculateNumVoxelsInComposedCreation(
    BaseCreationInWorld[] memory baseCreationsInWorld,
    uint256 rootVoxelTypesLength
  ) internal view returns (uint32) {
    uint32 numVoxels = uint32(rootVoxelTypesLength);
    for (uint32 i = 0; i < baseCreationsInWorld.length; i++) {
      BaseCreationInWorld memory baseCreation = baseCreationsInWorld[i];
      uint256 numVoxelsInBaseCreation = CreationRegistry.getNumVoxels(baseCreation.creationId);
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
    CreationRegistryData memory creation = CreationRegistry.get(creationId);
    VoxelCoord[] memory allRelativeCoords = new VoxelCoord[](creation.numVoxels);
    VoxelTypeData[] memory allVoxelTypes = new VoxelTypeData[](creation.numVoxels);

    VoxelCoord[] memory creationRelativeCoords = abi.decode(creation.relativePositions, (VoxelCoord[]));
    VoxelTypeData[] memory creationVoxelTypes = abi.decode(creation.voxelTypes, (VoxelTypeData[]));

    // 1) add all the (non-base) voxels in this creation to the arrays
    for (uint32 i = 0; i < creationRelativeCoords.length; i++) {
      allRelativeCoords[i] = creationRelativeCoords[i];
      allVoxelTypes[i] = creationVoxelTypes[i];
    }
    uint32 voxelIdx = uint32(creationRelativeCoords.length);

    // 2) for each child base creation, add all of its voxels (and its coords) to our voxels array (minus the deleted voxels)
    BaseCreation[] memory baseCreations = abi.decode(creation.baseCreations, (BaseCreation[]));

    for (uint32 i = 0; i < baseCreations.length; i++) {
      BaseCreation memory baseCreation = baseCreations[i];

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
          allRelativeCoords[voxelIdx] = add(baseCreation.coordOffset, childVoxelCoord);
          allVoxelTypes[voxelIdx] = childVoxelTypes[j];
          voxelIdx++;
        }
      }
    }
    return (allRelativeCoords, allVoxelTypes);
  }

  function convertBaseCreationsInWorldToBaseCreation(
    BaseCreationInWorld[] memory baseCreationsInWorld,
    VoxelCoord memory lowerSouthwestCorner
  ) internal pure returns (BaseCreation[] memory) {
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

  function hasDuplicateVoxelCoords(
    VoxelCoord[] memory coords
  ) internal pure returns (bool, VoxelCoord memory, VoxelCoord memory) {
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

  function getCreationHash(
    VoxelTypeData[] memory voxelTypes,
    VoxelCoord[] memory relativePositions
  ) internal pure returns (bytes32) {
    return bytes32(keccak256(abi.encode(voxelTypes, relativePositions)));
  }
}
