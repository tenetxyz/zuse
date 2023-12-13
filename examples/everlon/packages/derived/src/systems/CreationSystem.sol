// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { voxelCoordToString, voxelCoordsAreEqual, add, sub } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { ObjectTypeRegistry, ObjectTypeRegistryTableId } from "@tenet-registry/src/codegen/tables/ObjectTypeRegistry.sol";
import { CreationRegistryTableId, CreationRegistry, CreationRegistryData } from "@tenet-derived/src/codegen/Tables.sol";
import { VoxelCoord, CreationMetadata, CreationSpawns } from "@tenet-utils/src/Types.sol";
import { BaseCreation, BaseCreationInWorld } from "@tenet-derived/src/Types.sol";
import { REGISTRY_ADDRESS } from "@tenet-derived/src/Constants.sol";

uint256 constant MAX_BLOCKS_IN_CREATION = 100;

contract CreationSystem is System {
  function registerCreation(
    string memory name,
    string memory description,
    bytes32[] memory objectTypeIds,
    VoxelCoord[] memory voxelCoords,
    BaseCreationInWorld[] memory baseCreationsInWorld
  ) public returns (bytes32, VoxelCoord memory, bytes32[] memory, VoxelCoord[] memory) {
    for (uint256 i = 0; i < objectTypeIds.length; i++) {
      require(
        hasKey(
          IStore(REGISTRY_ADDRESS),
          ObjectTypeRegistryTableId,
          ObjectTypeRegistry.encodeKeyTuple(objectTypeIds[i])
        ),
        "CreationSystem: Object type ID has not been registered"
      );
    }
    for (uint256 i = 0; i < baseCreationsInWorld.length; i++) {
      require(
        hasKey(CreationRegistryTableId, CreationRegistry.encodeKeyTuple(baseCreationsInWorld[i].creationId)),
        "CreationSystem: Base creation ID has not been registered"
      );
    }
    CreationRegistryData memory creationData;

    // 1) get all of the voxelCoords of all voxels in the creation
    (VoxelCoord[] memory allVoxelCoordsInWorld, bytes32[] memory allObjectTypeIds) = getObjects(
      voxelCoords,
      objectTypeIds,
      baseCreationsInWorld
    );

    // 2) validate the creation
    validateCreation(allVoxelCoordsInWorld);

    // 3) find the lowestSouthWestCorner so we can center the voxels about the origin (lowerSouthwestCorner)
    VoxelCoord memory lowerSouthwestCorner = getLowerSouthwestCorner(allVoxelCoordsInWorld);

    bytes32 creationId;
    {
      // 4) reposition the voxels so the lowerSouthwestCorner is on the origin
      // Note: we do NOT need to reposition the voxels within base creations because they are already positioned relative to the base creation
      VoxelCoord[] memory relativePositions = repositionBlocksSoLowerSouthwestCornerIsOnOrigin(
        voxelCoords,
        lowerSouthwestCorner
      );
      creationData.relativePositions = abi.encode(relativePositions);
      creationId = getCreationHash(allObjectTypeIds, relativePositions);
      require(
        !hasKey(CreationRegistryTableId, CreationRegistry.encodeKeyTuple(creationId)),
        "CreationSystem: Creation has already been registered"
      );
    }

    {
      // 5) Reposition the base creations about the origin
      BaseCreation[] memory baseCreations = convertBaseCreationsInWorldToBaseCreation(
        baseCreationsInWorld,
        lowerSouthwestCorner
      );
      creationData.baseCreations = abi.encode(baseCreations);
    }

    // 6) write all the fields of the creation to the table
    creationData.numObjects = uint32(allVoxelCoordsInWorld.length);
    creationData.objectTypeIds = allObjectTypeIds;
    creationData.metadata = getMetadata(name, description);
    CreationRegistry.set(creationId, creationData);

    return (creationId, lowerSouthwestCorner, allObjectTypeIds, allVoxelCoordsInWorld);
  }

  function getMetadata(string memory name, string memory description) internal view returns (bytes memory) {
    return
      abi.encode(
        CreationMetadata({ creator: tx.origin, name: name, description: description, spawns: new CreationSpawns[](0) })
      );
  }

  function creationSpawned(bytes32 creationId) public returns (uint256) {
    address worldAddress = _msgSender();
    require(
      hasKey(CreationRegistryTableId, CreationRegistry.encodeKeyTuple(creationId)),
      "CreationSystem: Creation has not been registered"
    );
    CreationMetadata memory creationMetadata = abi.decode(CreationRegistry.getMetadata(creationId), (CreationMetadata));
    CreationSpawns[] memory creationSpawns = creationMetadata.spawns;
    bool found = false;
    uint256 newSpawnCount = 0;
    for (uint256 i = 0; i < creationSpawns.length; i++) {
      if (creationSpawns[i].worldAddress == worldAddress) {
        creationSpawns[i].numSpawns += 1;
        newSpawnCount = creationSpawns[i].numSpawns;
        creationMetadata.spawns = creationSpawns;
        CreationRegistry.setMetadata(creationId, abi.encode(creationMetadata));
        found = true;
        break;
      }
    }
    if (!found) {
      // this means, this is a new world, and we need to add it to the array
      CreationSpawns[] memory newCreationSpawns = new CreationSpawns[](creationSpawns.length + 1);
      for (uint256 i = 0; i < creationSpawns.length; i++) {
        newCreationSpawns[i] = creationSpawns[i];
      }
      newCreationSpawns[creationSpawns.length] = CreationSpawns({ worldAddress: worldAddress, numSpawns: 1 });
      creationMetadata.spawns = newCreationSpawns;
      newSpawnCount = 1;
      CreationRegistry.setMetadata(creationId, abi.encode(creationMetadata));
    }

    return newSpawnCount;
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
      VoxelCoord memory voxelCoord = voxelCoords[i];
      repositionedVoxelCoords[i] = VoxelCoord({
        x: voxelCoord.x - lowerSouthwestCorner.x,
        y: voxelCoord.y - lowerSouthwestCorner.y,
        z: voxelCoord.z - lowerSouthwestCorner.z
      });
    }
    return (repositionedVoxelCoords);
  }

  // Why not merge this function with getObjectsInCreation? It's because the coords that are returned by the objects in a registered creation
  // are RELATIVE to the lowerSouthWestCorner of the creation. But right now, we do NOT know what the lowerSouthWestCorner is, we only know
  // where all the baseCreationsInWorld are in the world.
  function getObjects(
    VoxelCoord[] memory rootVoxelCoords,
    bytes32[] memory rootObjectTypeIds,
    BaseCreationInWorld[] memory baseCreationsInWorld
  ) internal view returns (VoxelCoord[] memory, bytes32[] memory) {
    uint32 numObjects = calculateNumObjectsInComposedCreation(baseCreationsInWorld, rootObjectTypeIds.length);

    VoxelCoord[] memory allVoxelCoords = new VoxelCoord[](numObjects); // these are the coords of the object in the world. they are NOT relative
    bytes32[] memory allObjectTypeIds = new bytes32[](numObjects);

    // 1) add all the (non-base) voxels in this creation to the arrays
    for (uint32 i = 0; i < rootVoxelCoords.length; i++) {
      allVoxelCoords[i] = rootVoxelCoords[i];
      allObjectTypeIds[i] = rootObjectTypeIds[i];
    }

    uint32 objectIdx = uint32(rootVoxelCoords.length);

    for (uint32 i = 0; i < baseCreationsInWorld.length; i++) {
      BaseCreationInWorld memory baseCreationInWorld = baseCreationsInWorld[i];
      (VoxelCoord[] memory baseVoxelCoords, bytes32[] memory baseObjectTypeIds) = getObjectsInCreation(
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
            // this object is deleted, so don't add it
            isDeleted = true;
            numDeleted++;
            break;
          }
        }
        if (!isDeleted) {
          allVoxelCoords[objectIdx] = add(baseCreationInWorld.lowerSouthWestCornerInWorld, baseVoxelCoord);
          allObjectTypeIds[objectIdx] = baseObjectTypeIds[j];
          objectIdx++;
        }
      }

      require(
        numDeleted == baseCreationInWorld.deletedRelativeCoords.length,
        string(
          abi.encode(
            "you deleted objects in baseCreationInWorld.creationId: ",
            baseCreationInWorld.creationId,
            " that don't exist in the creation. Make sure that all baseCreationInWorld.deletedRelativeCoords are actually from the base creation"
          )
        )
      );
    }
    return (allVoxelCoords, allObjectTypeIds);
  }

  function calculateNumObjectsInComposedCreation(
    BaseCreationInWorld[] memory baseCreationsInWorld,
    uint256 rootObjectTypesLength
  ) internal view returns (uint32) {
    uint32 numObjects = uint32(rootObjectTypesLength);
    for (uint32 i = 0; i < baseCreationsInWorld.length; i++) {
      BaseCreationInWorld memory baseCreation = baseCreationsInWorld[i];
      uint256 numObjectsInBaseCreation = CreationRegistry.getNumObjects(baseCreation.creationId);
      uint256 numDeleteObjects = baseCreation.deletedRelativeCoords.length;
      require(
        numObjectsInBaseCreation > numDeleteObjects,
        string(
          abi.encode(
            "You cannot delete ",
            Strings.toString(uint256(numDeleteObjects)),
            " voxels, when the base creation has ",
            Strings.toString(uint256(numObjectsInBaseCreation)),
            " voxels"
          )
        )
      );

      numObjects += uint32(numObjectsInBaseCreation - numDeleteObjects);
    }
    return numObjects;
  }

  // we need to find out which voxels are not deleted
  // so we just need to compile a list of all the voxels in the base creations
  // then we need to remove the voxels that are deleted

  function getObjectsInCreation(bytes32 creationId) public view returns (VoxelCoord[] memory, bytes32[] memory) {
    CreationRegistryData memory creation = CreationRegistry.get(creationId);
    VoxelCoord[] memory allRelativeCoords = new VoxelCoord[](creation.numObjects);
    bytes32[] memory allObjectTypeIds = new bytes32[](creation.numObjects);

    VoxelCoord[] memory creationRelativeCoords = abi.decode(creation.relativePositions, (VoxelCoord[]));
    bytes32[] memory creationObjectTypeIds = creation.objectTypeIds;

    // 1) add all the (non-base) voxels in this creation to the arrays
    for (uint32 i = 0; i < creationRelativeCoords.length; i++) {
      allRelativeCoords[i] = creationRelativeCoords[i];
      allObjectTypeIds[i] = creationObjectTypeIds[i];
    }
    uint32 objectIdx = uint32(creationRelativeCoords.length);

    // 2) for each child base creation, add all of its voxels (and its coords) to our voxels array (minus the deleted voxels)
    BaseCreation[] memory baseCreations = abi.decode(creation.baseCreations, (BaseCreation[]));

    for (uint32 i = 0; i < baseCreations.length; i++) {
      BaseCreation memory baseCreation = baseCreations[i];

      (VoxelCoord[] memory childVoxelCoords, bytes32[] memory childObjectTypeIds) = getObjectsInCreation(
        baseCreation.creationId
      );

      // add each child object into our array (if it's not deleted)
      for (uint32 j = 0; j < childVoxelCoords.length; j++) {
        VoxelCoord memory childVoxelCoord = childVoxelCoords[j];
        bool isDeleted = false;
        for (uint32 k = 0; k < baseCreation.deletedRelativeCoords.length; k++) {
          VoxelCoord memory deletedRelativeCoord = baseCreation.deletedRelativeCoords[k];
          if (voxelCoordsAreEqual(childVoxelCoord, deletedRelativeCoord)) {
            // this object is deleted, so don't add it
            isDeleted = true;
            break;
          }
        }
        if (!isDeleted) {
          allRelativeCoords[objectIdx] = add(baseCreation.coordOffset, childVoxelCoord);
          allObjectTypeIds[objectIdx] = childObjectTypeIds[j];
          objectIdx++;
        }
      }
    }
    return (allRelativeCoords, allObjectTypeIds);
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
    bytes32[] memory objectTypeIds,
    VoxelCoord[] memory relativePositions
  ) internal pure returns (bytes32) {
    return bytes32(keccak256(abi.encode(objectTypeIds, relativePositions)));
  }
}
