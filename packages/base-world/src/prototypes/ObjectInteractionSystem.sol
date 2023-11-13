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
import { Metadata, MetadataTableId } from "@tenet-base-world/src/codegen/tables/Metadata.sol";
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

  function beforeRunInteraction(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) internal virtual {}

  function decodeToBoolAndBytes(bytes memory data) external pure returns (bool, bytes memory) {
    return abi.decode(data, (bool, bytes));
  }

  function runEventHandler(
    bytes32 centerObjectTypeId,
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) internal virtual returns (bytes memory) {
    (address eventHandlerAddress, bytes4 eventHandlerSelector) = getEventHandler(
      IStore(getRegistryAddress()),
      centerObjectTypeId
    );
    require(
      eventHandlerAddress != address(0) && objectEventHandlerSelector != bytes4(0),
      "Object eventHandler not defined"
    );

    (bool eventHandlerSuccess, bytes memory centerEntityActionData) = safeCall(
      eventHandlerAddress,
      abi.encodeWithSelector(eventHandlerSelector, centerObjectEntityId, neighbourObjectEntityIds),
      "object event handler selector"
    );

    return centerEntityActionData;
  }

  function runNeighbourInteractionsHelper(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntityId
  ) internal returns (bool) {
    bytes32 voxelTypeId = CAVoxelType.getVoxelTypeId(callerAddress, interactEntity);
    bytes32 neighbourVoxelTypeId = CAVoxelType.getVoxelTypeId(callerAddress, neighbourEntityId);
    return
      shouldRunInteractionForNeighbour(
        callerAddress,
        VoxelEntity({
          scale: VoxelTypeRegistry.getScale(IStore(getRegistryAddress()), voxelTypeId),
          entityId: interactEntity
        }),
        VoxelEntity({
          scale: VoxelTypeRegistry.getScale(IStore(getRegistryAddress()), neighbourVoxelTypeId),
          entityId: neighbourEntityId
        })
      );
  }

  function runNeighbourEventHandlers(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32 caInteractEntity,
    bytes32[] memory caNeighbourEntityIds
  ) internal returns (bytes32[] memory, bytes[] memory) {
    bytes32[] memory changedNeighbourEntities = new bytes32[](neighbourEntityIds.length);
    bytes[] memory neighbourEntitiesEventData = new bytes[](neighbourEntityIds.length);
    for (uint256 i = 0; i < neighbourEntityIds.length; i++) {
      if (neighbourEntityIds[i] != 0) {
        bytes32 neighbourVoxelTypeId = CAVoxelType.getVoxelTypeId(callerAddress, neighbourEntityIds[i]);
        if (!runNeighbourInteractionsHelper(callerAddress, interactEntity, neighbourEntityIds[i])) {
          continue;
        }

        bytes4 onNewNeighbourSelector = getOnNewNeighbourSelector(IStore(getRegistryAddress()), neighbourVoxelTypeId);
        if (onNewNeighbourSelector != bytes4(0)) {
          (bool success, bytes memory returnData) = safeCall(
            _world(),
            abi.encodeWithSelector(onNewNeighbourSelector, caNeighbourEntityIds[i], caInteractEntity),
            "onNewNeighbourSelector"
          );
          if (success) {
            try this.decodeToBoolAndBytes(returnData) returns (bool changedNeighbour, bytes memory entityEventData) {
              if (changedNeighbour) {
                changedNeighbourEntities[i] = caNeighbourEntityIds[i];
              }
              if (entityEventData.length != 0) {
                neighbourEntitiesEventData[i] = entityEventData;
              }
            } catch {}
          }
        }
      }
    }

    return (changedNeighbourEntities, neighbourEntitiesEventData);
  }

  function runSingleInteraction(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds
  ) internal returns (bytes32[] memory, EntityActionData[] memory) {
    bytes32 centerObjectEntityId = ObjectEntity.get(centerEntityId);
    bytes32[] memory neighbourObjectEntityIds = new bytes32[](neighbourEntityIds.length);
    for (uint256 i; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) != 0) {
        neighbourObjectEntityIds[i] = ObjectEntity.get(neighbourEntityIds[i]);
      }
    }
    beforeRunInteraction(centerObjectEntityId, neighbourObjectEntityIds);
    bytes32 centerObjectTypeId = ObjectType.get(centerEntityId);

    // Center Interaction
    bytes memory centerEntityActionData = runEventHandler(
      centerObjectTypeId,
      centerObjectEntityId,
      neighbourObjectEntityIds
    );

    // Neighbour Interactions
    (bytes32[] memory changedNeighbourEntities, bytes[] memory neighbourEntitiesActionData) = runNeighbourEventHandlers(
      callerAddress,
      interactEntity,
      neighbourEntityIds,
      caInteractEntity,
      caNeighbourEntityIds
    );

    // (bytes32[] memory changedEntities, bytes[] memory entitiesEventData) = abi.decode(returnData, (bytes32[], bytes[]));

    // EntityActionData[] memory allEntitiesActionData = new EntityActionData[](entitiesEventData.length);

    // for (uint256 i; i < entitiesEventData.length; i++) {
    //   if (entitiesEventData[i].length == 0) {
    //     continue;
    //   }

    //   allEntitiesActionData[i] = EntityActionData({
    //     entity: VoxelEntity({ scale: scale, entityId: i == 0 ? centerEntityId : neighbourEntities[i - 1] }),
    //     eventData: entitiesEventData[i]
    //   });
    // }

    return (changedEntities, allEntitiesActionData);
  }

  function runInteractions(bytes32 centerEntityId) public virtual returns (EntityActionData[] memory) {
    uint256 numUniqueEntitiesRan = KeysInTable.lengthKeys0(MetadataTableId);
    if (numUniqueEntitiesRan + 1 > MAX_UNIQUE_ENTITY_EVENT_HANDLERS_RUN) {
      return new EntityActionData[](0);
    }
    if (Metadata.get(centerEntityId) > MAX_SAME_ENTITY_EVENT_HANDLERS_RUN) {
      return new EntityActionData[](0);
    }
    Metadata.set(centerEntityId, Metadata.get(centerEntityId) + 1);

    bytes32[] memory centerEntitiesToRunQueue = new bytes32[](MAX_ENTITY_NEIGHBOUR_UPDATE_DEPTH);
    EntityActionData[] memory allEntitiesActionData = new EntityActionData[](MAX_ENTITY_NEIGHBOUR_UPDATE_DEPTH);
    uint256 centerEntitiesToRunQueueIdx = 0;
    uint256 entitesActionDataIdx = 0;
    uint256 useStackIdx = 0;

    // start with the center entity
    centerEntitiesToRunQueue[centerEntitiesToRunQueueIdx] = centerEntityId;
    useStackIdx = centerEntitiesToRunQueueIdx;

    while (useStackIdx < MAX_ENTITY_NEIGHBOUR_UPDATE_DEPTH) {
      bytes32 useCenterEntityId = centerEntitiesToRunQueue[useStackIdx];

      {
        (bytes32[] memory neighbourEntities, ) = calculateVonNeumannNeighbourEntities(useCenterEntityId);
        (bytes32[] memory changedEntities, EntityActionData[] memory entitiesEventData) = runSingleInteraction(
          useCenterEntityId,
          neighbourEntities
        );

        // If there are changed entities, we want to run object interactions again but with this new neighbour as the center
        for (uint256 i; i < changedEntities.length; i++) {
          if (uint256(changedEntities[i]) != 0) {
            centerEntitiesToRunQueueIdx++;
            require(
              centerEntitiesToRunQueueIdx < MAX_ENTITY_NEIGHBOUR_UPDATE_DEPTH,
              "ObjectInteractionSystem: Reached max depth"
            );
            centerEntitiesToRunQueue[centerEntitiesToRunQueueIdx] = changedEntities[i];
          }
        }

        for (uint256 i; i < entitiesEventData.length; i++) {
          if (entitiesEventData[i].eventData.length == 0) {
            continue;
          }
          {
            allEntitiesActionData[entitesActionDataIdx] = entitiesEventData[i];
          }
          entitesActionDataIdx++;
          require(
            entitesActionDataIdx < MAX_ENTITY_NEIGHBOUR_UPDATE_DEPTH,
            "ObjectInteractionSystem: Reached max depth"
          );
        }
      }

      // at this point, we've consumed the top of the stack,
      // so we can pop it, in this case, we just increment the stack index
      if (centerEntitiesToRunQueueIdx > useStackIdx) {
        useStackIdx++;
      } else {
        // this means we didnt any any updates, so we can break out of the loop
        break;
      }
    }

    return allEntitiesActionData;
  }
}
