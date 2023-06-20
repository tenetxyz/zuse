// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { VoxelCoord } from "../types.sol";
import { NUM_NEIGHBOURS, MAX_NEIGHBOUR_UPDATE_DEPTH } from "../Constants.sol";
import {Position, PositionData} from "../codegen/Tables.sol";
import { getEntitiesAtCoord, hasEntity } from "../utils.sol";

library BlockInteraction {

  function calculateNeighbourEntities(bytes32 centerEntity)
    public
    returns (bytes32[] memory)
  {
    bytes32[] memory centerNeighbourEntities = new bytes32[](NUM_NEIGHBOURS);
    PositionData memory baseCoord = Position.get(centerEntity);

    for (uint8 i = 0; i < centerNeighbourEntities.length; i++) {
      bytes32[] memory neighbourEntitiesAtPosition;
      if (i == 0) {
        neighbourEntitiesAtPosition = getEntitiesAtCoord(
          VoxelCoord({ x: baseCoord.x + 1, y: baseCoord.y, z: baseCoord.z })
        );
      } else if (i == 1) {
        neighbourEntitiesAtPosition = getEntitiesAtCoord(
          VoxelCoord({ x: baseCoord.x - 1, y: baseCoord.y, z: baseCoord.z })
        );
      } else if (i == 2) {
        neighbourEntitiesAtPosition = getEntitiesAtCoord(
          VoxelCoord({ x: baseCoord.x, y: baseCoord.y + 1, z: baseCoord.z })
        );
      } else if (i == 3) {
        neighbourEntitiesAtPosition = getEntitiesAtCoord(
          VoxelCoord({ x: baseCoord.x, y: baseCoord.y - 1, z: baseCoord.z })
        );
      } else if (i == 4) {
        neighbourEntitiesAtPosition = getEntitiesAtCoord(
          VoxelCoord({ x: baseCoord.x, y: baseCoord.y, z: baseCoord.z + 1 })
        );
      } else if (i == 5) {
        neighbourEntitiesAtPosition = getEntitiesAtCoord(
          VoxelCoord({ x: baseCoord.x, y: baseCoord.y, z: baseCoord.z - 1 })
        );
      }

      require(
        neighbourEntitiesAtPosition.length == 0 || neighbourEntitiesAtPosition.length == 1,
        "can not built at non-empty coord (BlockInteraction)"
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

  function runInteractionSystems(
    bytes32 centerEntity
  ) public {
    // get neighbour entities
    bytes32[] memory centerEntitiesToCheckStack = new bytes32[](MAX_NEIGHBOUR_UPDATE_DEPTH);
    uint256 centerEntitiesToCheckStackIdx = 0;
    uint256 useStackIdx = 0;

    // start with the center entity
    centerEntitiesToCheckStack[centerEntitiesToCheckStackIdx] = centerEntity;
    useStackIdx = centerEntitiesToCheckStackIdx;
    centerEntitiesToCheckStackIdx++;

    // Keep looping until there is no neighbour to process or we reached max depth
    while (useStackIdx < MAX_NEIGHBOUR_UPDATE_DEPTH) {
      // NOTE:
      // we'll go through each one until there is no more changed entities
      // order in which these systems are called should not matter since they all change their own components

      bytes32 useCenterEntityId = centerEntitiesToCheckStack[useStackIdx];
      bytes32[] memory useNeighbourEntities = calculateNeighbourEntities(useCenterEntityId);
      if (hasEntity(useNeighbourEntities)) {
        // call SignalSystem with centerEntity and neighbourEntities
        uint256[] memory changedSignalSystemEntityIds = signalSystem.executeTyped(
          useCenterEntityId,
          useNeighbourEntities
        );

        // if there are changed entities, we want to keep looping for this system
        for (uint256 i = 0; i < changedSignalSystemEntityIds.length; i++) {
          if (changedSignalSystemEntityIds[i] != 0) {
            centerEntitiesToCheckStack[centerEntitiesToCheckStackIdx] = changedSignalSystemEntityIds[i];
            centerEntitiesToCheckStackIdx++;
            if (centerEntitiesToCheckStackIdx >= MAX_NEIGHBOUR_UPDATE_DEPTH) {
              // TODO: Should tell the user that we reached max depth
              break;
            }
          }
        }

        // call SignalSourceSystem with centerEntity and neighbourEntities
        uint256[] memory changedSignalSourceSystemEntityIds = signalSourceSystem.executeTyped(
          useCenterEntityId,
          useNeighbourEntities
        );

        // if there are changed entities, we want to keep looping for this system
        for (uint256 i = 0; i < changedSignalSourceSystemEntityIds.length; i++) {
          if (changedSignalSourceSystemEntityIds[i] != 0) {
            centerEntitiesToCheckStack[centerEntitiesToCheckStackIdx] = changedSignalSourceSystemEntityIds[i];
            centerEntitiesToCheckStackIdx++;
            if (centerEntitiesToCheckStackIdx >= MAX_NEIGHBOUR_UPDATE_DEPTH) {
              // TODO: Should tell the user that we reached max depth
              break;
            }
          }
        }

        // call SignalSourceSystem with centerEntity and neighbourEntities
        uint256[] memory changedInvertedSignalSystemEntityIds = invertedSignalSystem.executeTyped(
          useCenterEntityId,
          useNeighbourEntities
        );

        // if there are changed entities, we want to keep looping for this system
        for (uint256 i = 0; i < changedInvertedSignalSystemEntityIds.length; i++) {
          if (changedInvertedSignalSystemEntityIds[i] != 0) {
            centerEntitiesToCheckStack[centerEntitiesToCheckStackIdx] = changedInvertedSignalSystemEntityIds[i];
            centerEntitiesToCheckStackIdx++;
            if (centerEntitiesToCheckStackIdx >= MAX_NEIGHBOUR_UPDATE_DEPTH) {
              // TODO: Should tell the user that we reached max depth
              break;
            }
          }
        }

        // call SignalSourceSystem with centerEntity and neighbourEntities
        uint256[] memory changedPoweredSystemEntityIds = poweredSystem.executeTyped(
          useCenterEntityId,
          useNeighbourEntities
        );

        // if there are changed entities, we want to keep looping for this system
        for (uint256 i = 0; i < changedPoweredSystemEntityIds.length; i++) {
          if (changedPoweredSystemEntityIds[i] != 0) {
            centerEntitiesToCheckStack[centerEntitiesToCheckStackIdx] = changedPoweredSystemEntityIds[i];
            centerEntitiesToCheckStackIdx++;
            if (centerEntitiesToCheckStackIdx >= MAX_NEIGHBOUR_UPDATE_DEPTH) {
              // TODO: Should tell the user that we reached max depth
              break;
            }
          }
        }

        uint256[] memory changedPistonSystemEntityIds = pistonSystem.executeTyped(
          useCenterEntityId,
          useNeighbourEntities
        );

        // if there are changed entities, we want to keep looping for this system
        for (uint256 i = 0; i < changedPistonSystemEntityIds.length; i++) {
          if (changedPistonSystemEntityIds[i] != 0) {
            centerEntitiesToCheckStack[centerEntitiesToCheckStackIdx] = changedPistonSystemEntityIds[i];
            centerEntitiesToCheckStackIdx++;
            if (centerEntitiesToCheckStackIdx >= MAX_NEIGHBOUR_UPDATE_DEPTH) {
              // TODO: Should tell the user that we reached max depth
              break;
            }
          }
        }
      }

      // at this point, we've consumed the top of the stack, so we can pop it, in this case, we just increment the stack index
      // check if we added any more
      if ((centerEntitiesToCheckStackIdx - 1) > useStackIdx) {
        useStackIdx++;
      } else {
        // this means we didnt any any updates, so we can break out of the loop
        break;
      }
    }
  }
}