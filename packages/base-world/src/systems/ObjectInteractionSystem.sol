// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";

import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { VoxelCoord, EntityActionData } from "@tenet-utils/src/Types.sol";
import { getEventHandlerSelector, getNeighbourEventHandlerSelector } from "@tenet-registry/src/Utils.sol";
import { getVonNeumannNeighbourEntities } from "@tenet-base-world/src/Utils.sol";

abstract contract ObjectInteractionSystem is System {
  function getRegistryAddress() internal pure virtual returns (address);

  function preRunInteraction(bytes32 centerObjectEntityId, bytes32[] memory neighbourObjectEntityIds) internal virtual;

  function shouldRunEvent(bytes32 objectEntityId) internal virtual returns (bool);

  function getNumMaxObjectsToRun() internal virtual returns (uint256);

  function decodeToBoolAndBytes(bytes memory data) external pure returns (bool, bytes memory) {
    return abi.decode(data, (bool, bytes));
  }

  function runEventHandler(
    bytes32 centerObjectTypeId,
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) internal virtual returns (bytes memory) {
    if (!shouldRunEvent(centerObjectEntityId)) {
      return new bytes(0);
    }
    (address eventHandlerAddress, bytes4 eventHandlerSelector) = getEventHandlerSelector(
      IStore(getRegistryAddress()),
      centerObjectTypeId
    );
    require(eventHandlerAddress != address(0) && eventHandlerSelector != bytes4(0), "Object eventHandler not defined");

    (bool eventHandlerSuccess, bytes memory centerEntityActionData) = safeCall(
      eventHandlerAddress,
      abi.encodeWithSelector(eventHandlerSelector, centerObjectEntityId, neighbourObjectEntityIds),
      "object event handler selector"
    );

    return centerEntityActionData;
  }

  function runNeighbourEventHandlers(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds,
    bytes32[] memory neighbourEntityIds
  ) internal returns (bytes32[] memory, bytes[] memory) {
    bytes32[] memory changedNeighbourEntities = new bytes32[](neighbourObjectEntityIds.length);
    bytes[] memory neighbourentitiesActionData = new bytes[](neighbourObjectEntityIds.length);
    for (uint256 i = 0; i < neighbourObjectEntityIds.length; i++) {
      if (uint256(neighbourObjectEntityIds[i]) == 0) {
        continue;
      }

      bytes32 neighbourObjectTypeId = ObjectType.get(neighbourEntityIds[i]);
      if (!shouldRunEvent(neighbourObjectEntityIds[i])) {
        continue;
      }

      (address neighbourEventHandlerAddress, bytes4 neighbourEventHandlerSelector) = getNeighbourEventHandlerSelector(
        IStore(getRegistryAddress()),
        neighbourObjectTypeId
      );
      require(
        neighbourEventHandlerAddress != address(0) && neighbourEventHandlerSelector != bytes4(0),
        "Object neighbourEventHandler not defined"
      );
      (bool neighbourEventHandlerSuccess, bytes memory neighbourEntityActionData) = safeCall(
        neighbourEventHandlerAddress,
        abi.encodeWithSelector(neighbourEventHandlerSelector, neighbourObjectEntityIds[i], centerObjectEntityId),
        "object neighbour event handler selector"
      );
      if (neighbourEventHandlerSuccess) {
        try this.decodeToBoolAndBytes(neighbourEntityActionData) returns (
          bool changedNeighbour,
          bytes memory entityEventData
        ) {
          if (changedNeighbour) {
            changedNeighbourEntities[i] = neighbourEntityIds[i];
          }
          if (entityEventData.length != 0) {
            neighbourentitiesActionData[i] = entityEventData;
          }
        } catch {}
      }
    }

    return (changedNeighbourEntities, neighbourentitiesActionData);
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
    preRunInteraction(centerObjectEntityId, neighbourObjectEntityIds);
    bytes32 centerObjectTypeId = ObjectType.get(centerEntityId);

    // Center Interaction
    bytes memory centerEntityActionData = runEventHandler(
      centerObjectTypeId,
      centerObjectEntityId,
      neighbourObjectEntityIds
    );

    // Neighbour Interactions
    (bytes32[] memory changedNeighbourEntities, bytes[] memory neighbourEntitiesActionData) = runNeighbourEventHandlers(
      centerObjectEntityId,
      neighbourObjectEntityIds,
      neighbourEntityIds
    );

    EntityActionData[] memory allEntitiesActionData = new EntityActionData[](neighbourEntitiesActionData.length + 1);
    allEntitiesActionData[0] = EntityActionData({ entityId: centerEntityId, actionData: centerEntityActionData });

    for (uint256 i; i < neighbourEntitiesActionData.length; i++) {
      if (neighbourEntitiesActionData[i].length == 0) {
        continue;
      }

      allEntitiesActionData[i + 1] = EntityActionData({
        entityId: neighbourEntityIds[i],
        actionData: neighbourEntitiesActionData[i]
      });
    }

    return (changedNeighbourEntities, allEntitiesActionData);
  }

  function runInteractions(bytes32 centerEntityId) public virtual returns (EntityActionData[] memory) {
    uint256 numMaxObjectsToRun = getNumMaxObjectsToRun();
    bytes32[] memory centerEntitiesToRunQueue = new bytes32[](numMaxObjectsToRun);
    EntityActionData[] memory allEntitiesActionData = new EntityActionData[](numMaxObjectsToRun);
    uint256 centerEntitiesToRunQueueIdx = 0;
    uint256 entitesActionDataIdx = 0;
    uint256 useQueueIdx = 0;

    // start with the center entity
    centerEntitiesToRunQueue[centerEntitiesToRunQueueIdx] = centerEntityId;
    useQueueIdx = centerEntitiesToRunQueueIdx;

    while (useQueueIdx < numMaxObjectsToRun) {
      bytes32 useCenterEntityId = centerEntitiesToRunQueue[useQueueIdx];

      (bytes32[] memory neighbourEntities, ) = getVonNeumannNeighbourEntities(IStore(_world()), useCenterEntityId);
      (bytes32[] memory changedEntities, EntityActionData[] memory entitiesActionData) = runSingleInteraction(
        useCenterEntityId,
        neighbourEntities
      );

      // If there are changed entities, we want to run object interactions again but with this new neighbour as the center
      for (uint256 i; i < changedEntities.length; i++) {
        if (uint256(changedEntities[i]) != 0) {
          centerEntitiesToRunQueueIdx++;
          require(centerEntitiesToRunQueueIdx < numMaxObjectsToRun, "ObjectInteractionSystem: Reached max depth");
          centerEntitiesToRunQueue[centerEntitiesToRunQueueIdx] = changedEntities[i];
        }
      }

      for (uint256 i; i < entitiesActionData.length; i++) {
        if (entitiesActionData[i].actionData.length == 0) {
          continue;
        }
        allEntitiesActionData[entitesActionDataIdx] = entitiesActionData[i];
        entitesActionDataIdx++;
        require(entitesActionDataIdx < numMaxObjectsToRun, "ObjectInteractionSystem: Reached max depth");
      }

      // at this point, we've consumed the front of the queue,
      // so we can pop it, in this case, we just increment the queue index
      if (centerEntitiesToRunQueueIdx > useQueueIdx) {
        useQueueIdx++;
      } else {
        // this means we didnt any any updates, so we can break out of the loop
        break;
      }
    }

    return allEntitiesActionData;
  }
}
