// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { VoxelCoord } from "@tenet-registry/src/Types.sol";
import { NUM_VOXEL_NEIGHBOURS, MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH } from "../Constants.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { VoxelTypesAllowed, Position, PositionData, PositionTableId, VoxelType, VoxelTypeData, VoxelTypeRegistry, VoxelInteractionExtension, VoxelInteractionExtensionTableId } from "@tenet-contracts/src/codegen/Tables.sol";
import { hasEntity, updateVoxelVariant } from "../Utils.sol";
import { safeCall } from "../Utils.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { AirVoxelID, DirtVoxelID } from "@tenet-base-ca/src/Constants.sol";

function getEntitiesAtCoord(VoxelCoord memory coord) view returns (bytes32[][] memory) {
  return getKeysWithValue(PositionTableId, Position.encode(coord.x, coord.y, coord.z));
}

function add(VoxelCoord memory a, VoxelCoord memory b) pure returns (VoxelCoord memory) {
  return VoxelCoord(a.x + b.x, a.y + b.y, a.z + b.z);
}

function calculateChildCoords(uint32 scale, VoxelCoord memory parentCoord) pure returns (VoxelCoord[] memory) {
  VoxelCoord[] memory childCoords = new VoxelCoord[](uint256(scale * scale * scale));
  uint256 index = 0;
  for (uint32 dz = 0; dz < scale; dz++) {
    for (uint32 dy = 0; dy < scale; dy++) {
      for (uint32 dx = 0; dx < scale; dx++) {
        childCoords[index] = VoxelCoord(
          parentCoord.x * int32(scale) + int32(dx),
          parentCoord.y * int32(scale) + int32(dy),
          parentCoord.z * int32(scale) + int32(dz)
        );
        index++;
      }
    }
  }
  return childCoords;
}

function calculateParentCoord(VoxelCoord memory childCoord, uint32 scale) pure returns (VoxelCoord memory) {
  int32 newX = childCoord.x / int32(scale);
  if (childCoord.x < 0) {
    newX -= 1; // We need to do this because Solidity rounds towards 0
  }
  int32 newY = childCoord.y / int32(scale);
  if (childCoord.y < 0) {
    newY -= 1; // We need to do this because Solidity rounds towards 0
  }
  int32 newZ = childCoord.z / int32(scale);
  if (childCoord.z < 0) {
    newZ -= 1; // We need to do this because Solidity rounds towards 0
  }
  return VoxelCoord(newX, newY, newZ);
}

contract VoxelInteractionSystem is System {
  int8[18] private NEIGHBOUR_COORD_OFFSETS = [
    int8(0),
    int8(0),
    int8(1),
    int8(0),
    int8(0),
    int8(-1),
    int8(1),
    int8(0),
    int8(0),
    int8(-1),
    int8(0),
    int8(0),
    int8(0),
    int8(1),
    int8(0),
    int8(0),
    int8(-1),
    int8(0)
  ];

  function initWorldVoxelTypes() public {
    bytes32[] memory allowedVoxelTypes = new bytes32[](2);
    allowedVoxelTypes[0] = AirVoxelID;
    allowedVoxelTypes[1] = DirtVoxelID;
    VoxelTypesAllowed.set(allowedVoxelTypes);
  }

  function calculateNeighbourEntities(uint32 scale, bytes32 centerEntity) public view returns (bytes32[] memory) {
    bytes32[] memory centerNeighbourEntities = new bytes32[](NUM_VOXEL_NEIGHBOURS);
    PositionData memory baseCoord = Position.get(scale, centerEntity);

    for (uint8 i = 0; i < centerNeighbourEntities.length; i++) {
      VoxelCoord memory neighbouringCoord = VoxelCoord(
        baseCoord.x + NEIGHBOUR_COORD_OFFSETS[i * 3],
        baseCoord.y + NEIGHBOUR_COORD_OFFSETS[i * 3 + 1],
        baseCoord.z + NEIGHBOUR_COORD_OFFSETS[i * 3 + 2]
      );

      bytes32[][] memory neighbourEntitiesAtPosition = getEntitiesAtCoord(neighbouringCoord);

      require(
        neighbourEntitiesAtPosition.length == 0 || neighbourEntitiesAtPosition.length == 1,
        "found more than one voxel in the same position. The VoxelInteractions cannot be calculated"
      );
      if (neighbourEntitiesAtPosition.length == 1) {
        // entity exists so add it to the list
        centerNeighbourEntities[i] = neighbourEntitiesAtPosition[0][0];
      } else {
        // no entity exists so add air
        // TODO: How do we deal with entities not created yet, but still in the world due to terrain generation
        centerNeighbourEntities[i] = 0;
      }
    }

    return centerNeighbourEntities;
  }

  function calculateChildEntities(uint32 scale, bytes32 entity) public view returns (bytes32[] memory) {
    if (scale == 2) {
      bytes32[] memory childEntities = new bytes32[](8);
      PositionData memory baseCoord = Position.get(scale, entity);
      VoxelCoord memory baseVoxelCoord = VoxelCoord({ x: baseCoord.x, y: baseCoord.y, z: baseCoord.z });
      VoxelCoord[] memory eightBlockVoxelCoords = calculateChildCoords(scale, baseVoxelCoord);

      for (uint8 i = 0; i < 8; i++) {
        bytes32[][] memory allEntitiesAtPosition = getEntitiesAtCoord(eightBlockVoxelCoords[i]);
        // filter for the ones with scale-1
        bytes32 childEntityAtPosition;
        for (uint256 j = 0; j < allEntitiesAtPosition.length; j++) {
          if (uint256(allEntitiesAtPosition[j][0]) == scale - 1) {
            if (childEntityAtPosition != 0) {
              revert("found more than one voxel in the same position when calculating child entities");
            }
            childEntityAtPosition = allEntitiesAtPosition[j][1];
          }
        }
        if (childEntityAtPosition == 0) {
          revert("found no child entity");
        }

        childEntities[i] = childEntityAtPosition;
      }

      return childEntities;
    }

    return new bytes32[](0);
  }

  function calculateParentEntity(uint32 scale, bytes32 entity) public view returns (bytes32) {
    bytes32 parentEntity;
    if (scale == 1) {
      PositionData memory baseCoord = Position.get(scale, entity);
      VoxelCoord memory baseVoxelCoord = VoxelCoord({ x: baseCoord.x, y: baseCoord.y, z: baseCoord.z });
      VoxelCoord memory parentVoxelCoord = calculateParentCoord(baseVoxelCoord, scale);
      bytes32[][] memory allEntitiesAtPosition = getEntitiesAtCoord(parentVoxelCoord);
      // filter for the ones with scale + 1
      for (uint256 j = 0; j < allEntitiesAtPosition.length; j++) {
        if (uint256(allEntitiesAtPosition[j][0]) == scale + 1) {
          if (parentEntity != 0) {
            revert("found more than one voxel in the same position when calculating parent entities");
          }
          parentEntity = allEntitiesAtPosition[j][1];
        }
      }
      if (parentEntity == 0) {
        // TODO: it's not always there
        // revert("found no parent entity");
      }
    }

    return parentEntity;
  }

  function enterCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes32 entity
  ) public returns (bytes memory) {
    return
      safeCall(
        caAddress,
        abi.encodeWithSignature("enterWorld(bytes32,(int32,int32,int32),bytes32)", voxelTypeId, coord, entity),
        string(abi.encode("enterWorld ", voxelTypeId, " ", coord, " ", entity))
      );
  }

  function exitCA(address caAddress, bytes32 entity) public returns (bytes memory) {
    return
      safeCall(
        caAddress,
        abi.encodeWithSignature("exitWorld(bytes32)", entity),
        string(abi.encode("exitWorld ", entity))
      );
  }

  function readCAVoxelTypes(address caAddress, bytes32 entity) public returns (CAVoxelTypeData memory) {
    return CAVoxelType.get(IStore(caAddress), address(this), entity);
  }

  function runCA(address caAddress, uint32 scale, bytes32 entity) public {
    // Run interaction logic
    bytes32[] memory neighbourEntityIds = calculateNeighbourEntities(scale, entity);
    bytes32[] memory childEntityIds = calculateChildEntities(scale, entity);
    bytes32 parentEntity = calculateParentEntity(scale, entity);
    bytes memory returnData = safeCall(
      caAddress,
      abi.encodeWithSignature(
        "runInteraction(bytes32,bytes32[],bytes32[],bytes32[])",
        entity,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      ),
      string(abi.encode("runInteraction ", entity, " ", neighbourEntityIds, " ", childEntityIds, " ", parentEntity))
    );
    bytes32[] memory changedEntities = abi.decode(returnData, (bytes32[]));

    // Update VoxelType and Position at this level to match the CA
    for (uint256 i = 0; i < changedEntities.length; i++) {
      bytes32 changedEntity = changedEntities[i];
      CAVoxelTypeData memory changedEntityVoxelType = CAVoxelType.get(IStore(caAddress), address(this), changedEntity);
      // Update VoxelType
      VoxelType.set(
        scale,
        changedEntities[i],
        changedEntityVoxelType.voxelTypeId,
        changedEntityVoxelType.voxelVariantId
      );
      // TODO: Do we need this?
      // Position should not change of the entity
      // Position.set(scale, changedEntities[i], coord.x, coord.y, coord.z);
    }
  }

  function runInteractionSystems(bytes32 centerEntity) public {
    address world = _world();

    // get neighbour entities
    bytes32[] memory centerEntitiesToCheckStack = new bytes32[](MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH);
    uint256 centerEntitiesToCheckStackIdx = 0;
    uint256 useStackIdx = 0;

    // start with the center entity
    centerEntitiesToCheckStack[centerEntitiesToCheckStackIdx] = centerEntity;
    useStackIdx = centerEntitiesToCheckStackIdx;

    // Keep looping until there is no neighbour to process or we reached max depth
    while (useStackIdx < MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH) {
      // NOTE:
      // we'll go through each one until there is no more changed entities
      // order in which these systems are called should not matter since they all change their own components
      bytes32 useCenterEntityId = centerEntitiesToCheckStack[useStackIdx];
      bytes32[] memory useNeighbourEntities = calculateNeighbourEntities(1, useCenterEntityId);
      if (!hasEntity(useNeighbourEntities)) {
        // if no neighbours, then we don't run any voxel interactions because there would be none
        break;
      }

      // Go over all registered extensions and call them
      bytes32[][] memory extensions = getKeysInTable(VoxelInteractionExtensionTableId);
      for (uint256 i; i < extensions.length; i++) {
        // TODO: Should filter which ones to call based on key/some config passed by user
        bytes16 extensionNamespace = bytes16(extensions[i][0]);
        bytes4 extensionEventHandler = bytes4(extensions[i][1]);

        // TODO: Add error handling
        // TODO: Remove require on release (there is an implicit require in safeCall)
        bytes memory extensionReturnData = safeCall(
          world,
          abi.encodeWithSelector(extensionEventHandler, useCenterEntityId, useNeighbourEntities),
          "ExtensionEventHandler"
        );
        bool extensionSuccess = true; // TODO: clean this up on release
        if (extensionSuccess) {
          (bytes32 changedCenterEntityId, bytes32[] memory changedNeighbourEntityIds) = abi.decode(
            extensionReturnData,
            (bytes32, bytes32[])
          );

          if (uint256(changedCenterEntityId) != 0) {
            centerEntitiesToCheckStackIdx++;
            require(
              centerEntitiesToCheckStackIdx < MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH,
              "VoxelInteractionSystem: Reached max depth"
            );
            centerEntitiesToCheckStack[centerEntitiesToCheckStackIdx] = changedCenterEntityId;
          }

          // If there are changed entities, we want to run voxel interactions again but with this new neighbour as the center
          for (uint256 j; j < changedNeighbourEntityIds.length; j++) {
            if (uint256(changedNeighbourEntityIds[j]) != 0) {
              centerEntitiesToCheckStackIdx++;
              require(
                centerEntitiesToCheckStackIdx < MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH,
                "VoxelInteractionSystem: Reached max depth"
              );
              centerEntitiesToCheckStack[centerEntitiesToCheckStackIdx] = changedNeighbourEntityIds[j];
            }
          }
        }
      }

      // at this point, we've consumed the top of the stack,
      // so we can pop it, in this case, we just increment the stack index
      if (centerEntitiesToCheckStackIdx > useStackIdx) {
        useStackIdx++;
      } else {
        // this means we didnt any any updates, so we can break out of the loop
        break;
      }
    }

    // Go through all the center entities that had an event run, and run its variant selector
    for (uint256 i = 0; i <= centerEntitiesToCheckStackIdx; i++) {
      bytes32 centerEntityId = centerEntitiesToCheckStack[i];
      // TODO: do we know for sure voxel type exists?
      updateVoxelVariant(_world(), centerEntityId);
    }
  }
}
