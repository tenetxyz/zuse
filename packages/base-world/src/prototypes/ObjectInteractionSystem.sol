// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelEntity, EntityActionData } from "@tenet-utils/src/Types.sol";
import { hasEntity } from "@tenet-utils/src/Utils.sol";
import { KeysInTable } from "@latticexyz/world/src/modules/keysintable/tables/KeysInTable.sol";
import { callOrRevert } from "@tenet-utils/src/CallUtils.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { Interactions, InteractionsTableId } from "@tenet-base-world/src/codegen/tables/Interactions.sol";
import { MAX_ENTITY_NEIGHBOUR_UPDATE_DEPTH, MAX_UNIQUE_ENTITY_INTERACTIONS_RUN, MAX_SAME_VOXEL_INTERACTION_RUN } from "@tenet-utils/src/Constants.sol";
import { Position, PositionData } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { positionDataToVoxelCoord, getEntityAtCoord, calculateChildCoords, calculateParentCoord } from "@tenet-base-world/src/Utils.sol";
import { VoxelType, VoxelTypeData } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { getEntityAtCoord, calculateChildCoords, calculateParentCoord } from "@tenet-base-world/src/Utils.sol";
import { runInteraction, enterWorld, exitWorld, activateVoxel, moveLayer, updateVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { MAX_UNIQUE_ENTITY_EVENT_HANDLERS_RUN, MAX_SAME_ENTITY_EVENT_HANDLERS_RUN, MAX_ENTITY_NEIGHBOUR_UPDATE_DEPTH } from "@tenet-base-world/src/Constants.sol";

abstract contract ObjectInteractionSystem is System {
  function getRegistryAddress() internal pure override returns (address);

  function calculateVonNeumannNeighbourEntities(
    bytes32 centerEntityId
  ) public view virtual returns (bytes32[] memory, VoxelCoord[] memory) {
    VoxelCoord memory centerCoord = positionDataToVoxelCoord(Position.get(centerEntityId));
    VoxelCoord[] memory neighbourCoords = getVonNeumannNeighbours(centerCoord);
    bytes32[] memory neighbourEntities = new bytes32[](neighbourCoords.length);

    for (uint i = 0; i < neighbourCoords.length; i++) {
      bytes32 neighbourEntity = getEntityAtCoord(neighbourCoords[i]);
      if (uint256(neighbourEntity) != 0) {
        neighbourEntities[i] = neighbourEntity;
      }
    }

    return (neighbourEntities, neighbourCoords);
  }

  function beforeRunInteraction(VoxelEntity memory entity) internal virtual {}

  function runInteractionWrapper(
    address caAddress,
    uint32 scale,
    bytes32 centerEntityId,
    bytes4 useInteractionSelector
  ) internal returns (bytes32[] memory, EntityActionData[] memory) {
    VoxelEntity memory centerEntity = VoxelEntity({ entityId: centerEntityId, scale: scale });
    (bytes32[] memory neighbourEntities, ) = IWorld(_world()).calculateNeighbourEntities(centerEntity);

    bytes memory returnData;
    {
      bytes32[] memory childEntityIds = IWorld(_world()).calculateChildEntities(centerEntity);
      bytes32 parentEntity = IWorld(_world()).calculateParentEntity(centerEntity);
      beforeRunInteraction(centerEntity);
      // Run interaction logic
      returnData = runInteraction(
        caAddress,
        useInteractionSelector,
        centerEntityId,
        neighbourEntities,
        childEntityIds,
        parentEntity
      );
    }
    (bytes32[] memory changedEntities, bytes[] memory entitiesEventData) = abi.decode(returnData, (bytes32[], bytes[]));

    EntityActionData[] memory allEntitiesEventData = new EntityActionData[](entitiesEventData.length);

    for (uint256 i; i < entitiesEventData.length; i++) {
      if (entitiesEventData[i].length == 0) {
        continue;
      }

      allEntitiesEventData[i] = EntityActionData({
        entity: VoxelEntity({ scale: scale, entityId: i == 0 ? centerEntityId : neighbourEntities[i - 1] }),
        eventData: entitiesEventData[i]
      });
    }

    return (changedEntities, allEntitiesEventData);
  }

  function runObjectEventHandler(bytes32 centerEntityId) public virtual returns (EntityActionData[] memory) {
    uint256 numUniqueEntitiesRan = KeysInTable.lengthKeys0(MetadataTableId);
    if (numUniqueEntitiesRan + 1 > MAX_UNIQUE_ENTITY_EVENT_HANDLERS_RUN) {
      return new EntityActionData[](0);
    }
    if (Metadata.get(centerEntityId) > MAX_SAME_ENTITY_EVENT_HANDLERS_RUN) {
      return new EntityActionData[](0);
    }
    Metadata.set(centerEntityId, Metadata.get(centerEntityId) + 1);

    bytes32[] memory centerEntitiesToCheckStack = new bytes32[](MAX_ENTITY_NEIGHBOUR_UPDATE_DEPTH);
    EntityActionData[] memory allEntitiesEventData = new EntityActionData[](MAX_ENTITY_NEIGHBOUR_UPDATE_DEPTH);
    uint256 centerEntitiesToCheckStackIdx = 0;
    uint256 entitesEventDataIdx = 0;
    uint256 useStackIdx = 0;

    // start with the center entity
    centerEntitiesToCheckStack[centerEntitiesToCheckStackIdx] = centerEntityId;
    useStackIdx = centerEntitiesToCheckStackIdx;

    while (useStackIdx < MAX_ENTITY_NEIGHBOUR_UPDATE_DEPTH) {
      bytes32 useCenterEntityId = centerEntitiesToCheckStack[useStackIdx];

      {
        (bytes32[] memory changedEntities, EntityActionData[] memory entitiesEventData) = runInteractionWrapper(
          caAddress,
          entity.scale,
          useCenterEntityId,
          useInteractionSelector
        );

        // If there are changed entities, we want to run voxel interactions again but with this new neighbour as the center
        for (uint256 i; i < changedEntities.length; i++) {
          if (uint256(changedEntities[i]) != 0) {
            centerEntitiesToCheckStackIdx++;
            require(
              centerEntitiesToCheckStackIdx < MAX_ENTITY_NEIGHBOUR_UPDATE_DEPTH,
              "ObjectInteractionSystem: Reached max depth"
            );
            centerEntitiesToCheckStack[centerEntitiesToCheckStackIdx] = changedEntities[i];
          }
        }

        for (uint256 i; i < entitiesEventData.length; i++) {
          if (entitiesEventData[i].eventData.length == 0) {
            continue;
          }
          {
            allEntitiesEventData[entitesEventDataIdx] = entitiesEventData[i];
          }
          entitesEventDataIdx++;
          require(
            entitesEventDataIdx < MAX_ENTITY_NEIGHBOUR_UPDATE_DEPTH,
            "ObjectInteractionSystem: Reached max depth"
          );
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

    return allEntitiesEventData;
  }
}
