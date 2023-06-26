// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { VoxelCoord } from "../types.sol";
import { NUM_VOXEL_NEIGHBOURS, MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH } from "../Constants.sol";
import { Position, PositionData, VoxelType, VoxelTypeData, VoxelTypeRegistry, VoxelInteractionExtension, VoxelInteractionExtensionTableId } from "../codegen/Tables.sol";
import { getEntitiesAtCoord, hasEntity, staticcallFunctionSelector, runVariantSelector } from "../utils.sol";

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

  function calculateNeighbourEntities(bytes32 centerEntity) public view returns (bytes32[] memory) {
    bytes32[] memory centerNeighbourEntities = new bytes32[](NUM_VOXEL_NEIGHBOURS);
    PositionData memory baseCoord = Position.get(centerEntity);

    for (uint8 i = 0; i < centerNeighbourEntities.length; i++) {
      VoxelCoord memory neighbouringCoord = VoxelCoord(
        baseCoord.x + NEIGHBOUR_COORD_OFFSETS[i * 3],
        baseCoord.y + NEIGHBOUR_COORD_OFFSETS[i * 3 + 1],
        baseCoord.z + NEIGHBOUR_COORD_OFFSETS[i * 3 + 2]
      );

      bytes32[] memory neighbourEntitiesAtPosition = getEntitiesAtCoord(neighbouringCoord);

      require(
        neighbourEntitiesAtPosition.length == 0 || neighbourEntitiesAtPosition.length == 1,
        "can not built at non-empty coord (VoxelInteraction)"
      );
      if (neighbourEntitiesAtPosition.length == 1) {
        // entity exists so add it to the list
        centerNeighbourEntities[i] = neighbourEntitiesAtPosition[0];
      } else {
        // no entity exists so add air
        // TODO: How do we deal with entities not created yet, but still in the world due to terrain generation
        centerNeighbourEntities[i] = 0;
      }
    }

    return centerNeighbourEntities;
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
      bytes32[] memory useNeighbourEntities = calculateNeighbourEntities(useCenterEntityId);
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
        (bool extensionSuccess, bytes memory extensionReturnData) = world.call(
          abi.encodeWithSelector(extensionEventHandler, useCenterEntityId, useNeighbourEntities)
        );
        // TODO: Add error handling
        require(extensionSuccess, "VoxelInteractionSystem: Extension call failed");
        if (extensionSuccess) {
          bytes32[] memory changedExtensionEntityIds = abi.decode(extensionReturnData, (bytes32[]));

          // If there are changed entities, we want to run voxel interactions again but with this new neighbour as the center
          for (uint256 j; j < changedExtensionEntityIds.length; j++) {
            if (uint256(changedExtensionEntityIds[j]) != 0) {
              centerEntitiesToCheckStackIdx++;
              centerEntitiesToCheckStack[centerEntitiesToCheckStackIdx] = changedExtensionEntityIds[j];
              require(
                centerEntitiesToCheckStackIdx < MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH,
                "VoxelInteractionSystem: Reached max depth"
              );
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
      runVariantSelector(_world(), centerEntityId);
    }
  }
}
