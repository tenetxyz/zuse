// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { VoxelCoord, EntityActionData, Action } from "@tenet-utils/src/Types.sol";
import { getEventHandlerSelector, getNeighbourEventHandlerSelector } from "@tenet-registry/src/Utils.sol";
import { getVonNeumannNeighbourEntities } from "@tenet-base-world/src/Utils.sol";
import { IWorldObjectEventSystem } from "@tenet-base-simulator/src/codegen/world/IWorldObjectEventSystem.sol";
import { REGISTRY_ADDRESS } from "@tenet-base-world/src/Constants.sol";

abstract contract ObjectInteractionSystem is System {
  function getSimulatorAddress() internal pure virtual returns (address);

  function preRunInteraction(bytes32 centerObjectEntityId, bytes32[] memory neighbourObjectEntityIds) internal virtual {
    IWorldObjectEventSystem(getSimulatorAddress()).preRunObjectInteraction(
      centerObjectEntityId,
      neighbourObjectEntityIds
    );
  }

  function shouldRunEvent(bytes32 objectEntityId) internal virtual returns (bool);

  function getNumMaxObjectsToRun() internal pure virtual returns (uint256);

  function decodeToBoolAndActionArray(bytes memory data) external pure returns (bool, Action[] memory) {
    return abi.decode(data, (bool, Action[]));
  }

  function decodeActionArray(bytes memory data) external pure returns (Action[] memory) {
    return abi.decode(data, (Action[]));
  }

  function runEventHandler(
    bytes32 centerObjectTypeId,
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) internal virtual returns (Action[] memory) {
    if (!shouldRunEvent(centerObjectEntityId)) {
      return new Action[](0);
    }
    (address eventHandlerAddress, bytes4 eventHandlerSelector) = getEventHandlerSelector(
      IStore(REGISTRY_ADDRESS),
      centerObjectTypeId
    );
    require(
      eventHandlerAddress != address(0) && eventHandlerSelector != bytes4(0),
      "ObjectInteractionSystem: Object eventHandler not defined"
    );

    (bool eventHandlerSuccess, bytes memory centerEntityActionData) = safeCall(
      eventHandlerAddress,
      abi.encodeWithSelector(eventHandlerSelector, centerObjectEntityId, neighbourObjectEntityIds),
      "object event handler selector"
    );
    if (eventHandlerSuccess) {
      try this.decodeActionArray(centerEntityActionData) returns (Action[] memory entityActionData) {
        return entityActionData;
      } catch {}
    }

    return new Action[](0);
  }

  function runNeighbourEventHandlers(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds,
    bytes32[] memory neighbourEntityIds
  ) internal returns (bytes32[] memory changedNeighbourEntities, Action[][] memory neighbourentitiesActionData) {
    changedNeighbourEntities = new bytes32[](neighbourObjectEntityIds.length);
    neighbourentitiesActionData = new Action[][](neighbourObjectEntityIds.length);
    for (uint256 i = 0; i < neighbourObjectEntityIds.length; i++) {
      if (uint256(neighbourObjectEntityIds[i]) == 0) {
        continue;
      }

      if (!shouldRunEvent(neighbourObjectEntityIds[i])) {
        continue;
      }

      bytes32 neighbourObjectTypeId = ObjectType.get(neighbourEntityIds[i]);
      (address neighbourEventHandlerAddress, bytes4 neighbourEventHandlerSelector) = getNeighbourEventHandlerSelector(
        IStore(REGISTRY_ADDRESS),
        neighbourObjectTypeId
      );
      require(
        neighbourEventHandlerAddress != address(0) && neighbourEventHandlerSelector != bytes4(0),
        "ObjectInteractionSystem: Object neighbourEventHandler not defined"
      );
      (bool neighbourEventHandlerSuccess, bytes memory neighbourEntityActionData) = safeCall(
        neighbourEventHandlerAddress,
        abi.encodeWithSelector(neighbourEventHandlerSelector, neighbourObjectEntityIds[i], centerObjectEntityId),
        "object neighbour event handler selector"
      );
      if (neighbourEventHandlerSuccess) {
        try this.decodeToBoolAndActionArray(neighbourEntityActionData) returns (
          bool changedNeighbour,
          Action[] memory entityActionData
        ) {
          if (changedNeighbour) {
            changedNeighbourEntities[i] = neighbourEntityIds[i];
          }
          neighbourentitiesActionData[i] = entityActionData;
        } catch {}
      }
    }

    return (changedNeighbourEntities, neighbourentitiesActionData);
  }

  function runSingleInteraction(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds
  ) internal returns (bytes32[] memory) {
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
    Action[] memory centerEntityActionData = runEventHandler(
      centerObjectTypeId,
      centerObjectEntityId,
      neighbourObjectEntityIds
    );

    // Neighbour Interactions
    (
      bytes32[] memory changedNeighbourEntities,
      Action[][] memory neighbourEntitiesActionData
    ) = runNeighbourEventHandlers(centerObjectEntityId, neighbourObjectEntityIds, neighbourEntityIds);

    bytes32[] memory changedEntities = new bytes32[](changedNeighbourEntities.length + 1);
    bool centerRanActions = IWorld(_world()).actionHandler(
      EntityActionData({ entityId: centerEntityId, actions: centerEntityActionData })
    );
    if (centerRanActions) {
      changedEntities[0] = centerEntityId;
    }

    for (uint256 i; i < neighbourEntitiesActionData.length; i++) {
      if (neighbourEntitiesActionData[i].length == 0) {
        continue;
      }

      bool neighbourRanActions = IWorld(_world()).actionHandler(
        EntityActionData({ entityId: neighbourEntityIds[i], actions: neighbourEntitiesActionData[i] })
      );
      if (neighbourRanActions) {
        changedEntities[i + 1] = neighbourEntityIds[i];
      }
    }

    for (uint256 i; i < changedNeighbourEntities.length; i++) {
      if (uint256(changedNeighbourEntities[i]) != 0) {
        changedEntities[i + 1] = changedNeighbourEntities[i];
      }
    }

    return (changedEntities);
  }

  function runInteractions(bytes32 centerEntityId) public virtual {
    uint256 numMaxObjectsToRun = getNumMaxObjectsToRun();
    bytes32[] memory centerEntitiesToRunQueue = new bytes32[](numMaxObjectsToRun);
    uint256 centerEntitiesToRunQueueIdx = 0;
    uint256 useQueueIdx = 0;

    // start with the center entity
    centerEntitiesToRunQueue[centerEntitiesToRunQueueIdx] = centerEntityId;
    useQueueIdx = centerEntitiesToRunQueueIdx;

    while (useQueueIdx < numMaxObjectsToRun) {
      bytes32 useCenterEntityId = centerEntitiesToRunQueue[useQueueIdx];

      (bytes32[] memory neighbourEntities, ) = getVonNeumannNeighbourEntities(IStore(_world()), useCenterEntityId);
      bytes32[] memory changedEntities = runSingleInteraction(useCenterEntityId, neighbourEntities);

      // If there are changed entities, we want to run object interactions again but with this new neighbour as the center
      for (uint256 i; i < changedEntities.length; i++) {
        if (uint256(changedEntities[i]) != 0) {
          centerEntitiesToRunQueueIdx++;
          require(centerEntitiesToRunQueueIdx < numMaxObjectsToRun, "ObjectInteractionSystem: Reached max depth");
          centerEntitiesToRunQueue[centerEntitiesToRunQueueIdx] = changedEntities[i];
        }
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
  }
}
