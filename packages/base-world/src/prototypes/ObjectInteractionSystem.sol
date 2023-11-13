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

  function beforeRunInteraction(bytes32 centerEntityId, bytes32[] memory neighbourEntityIds) internal virtual {}

  function decodeToBoolAndBytes(bytes memory data) external pure returns (bool, bytes memory) {
    return abi.decode(data, (bool, bytes));
  }

  function runEventHandler(
    bytes4 interactionSelector,
    bytes32 voxelTypeId,
    bytes32 caInteractEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal virtual returns (bytes32, bytes memory) {
    bytes32 changedCenterEntityId;
    bytes memory centerEntityEventData;

    {
      // handle base voxel types
      bytes32 baseVoxelTypeId = VoxelTypeRegistry.getBaseVoxelTypeId(IStore(getRegistryAddress()), voxelTypeId);
      if (baseVoxelTypeId != voxelTypeId) {
        (bytes32 insideChangedCenterEntityId, bytes memory insideCenterEntityEventData) = voxelRunInteraction(
          bytes4(0),
          baseVoxelTypeId,
          caInteractEntity,
          caNeighbourEntityIds,
          childEntityIds,
          parentEntity
        ); // recursive, so we get the entire stack of russian dolls

        if (changedCenterEntityId == 0 && insideChangedCenterEntityId != 0) {
          changedCenterEntityId = insideChangedCenterEntityId;
        }

        if (centerEntityEventData.length == 0 && insideCenterEntityEventData.length != 0) {
          centerEntityEventData = insideCenterEntityEventData;
        }
      }
    }
    bytes4 useinteractionSelector = 0;
    {
      InteractionSelector[] memory interactionSelectors = getInteractionSelectors(
        IStore(getRegistryAddress()),
        voxelTypeId
      );
      if (interactionSelector != bytes4(0)) {
        for (uint256 i = 0; i < interactionSelectors.length; i++) {
          if (interactionSelectors[i].interactionSelector == interactionSelector) {
            useinteractionSelector = interactionSelector;
            break;
          }
        }
      } else {
        // Call mind to figure out whch voxel interaction to run
        require(hasKey(CAMindTableId, CAMind.encodeKeyTuple(caInteractEntity)), "Mind does not exist");
        // bytes4 mindSelector = CAMind.getMindSelector(caInteractEntity);

        if (CAMind.getMindSelector(caInteractEntity) != bytes4(0)) {
          // call mind to figure out which interaction selector to use
          (bool mindSuccess, bytes memory mindReturnData) = safeCall(
            _world(),
            abi.encodeWithSelector(
              CAMind.getMindSelector(caInteractEntity),
              voxelTypeId,
              caInteractEntity,
              caNeighbourEntityIds,
              childEntityIds,
              parentEntity
            ),
            "mindSelector"
          );
          if (mindSuccess) {
            try this.decodeToBytes4(mindReturnData) returns (bytes4 decodedValue) {
              useinteractionSelector = decodedValue;
            } catch {}
            bool validSelector = false;
            for (uint256 i = 0; i < interactionSelectors.length; i++) {
              if (interactionSelectors[i].interactionSelector == useinteractionSelector) {
                validSelector = true;
                break;
              }
            }
            if (!validSelector) {
              useinteractionSelector = bytes4(0);
            }
          }
          if (useinteractionSelector == bytes4(0)) {
            if (interactionSelectors.length > 0) {
              // Note: we could return and not run any if the mind doesn't pick an interaction
              // however, we run the first one instead for voxel types to ensure specific behaviour always runs
              useinteractionSelector = interactionSelectors[0].interactionSelector;
            } else {
              // This voxel has no interaction selectors, so we don't run any interaction
              return (changedCenterEntityId, centerEntityEventData);
            }
          }
        } else {
          if (interactionSelectors.length > 0) {
            // use the first one, if there's only one
            useinteractionSelector = interactionSelectors[0].interactionSelector;
          } else {
            // This voxel has no mind and no interaction selector, so we don't run any interaction
            return (changedCenterEntityId, centerEntityEventData);
          }
        }
      }
    }
    require(useinteractionSelector != 0, "Interaction selector not found");

    {
      (bool success, bytes memory returnData) = safeCall(
        _world(),
        abi.encodeWithSelector(
          useinteractionSelector,
          caInteractEntity,
          caNeighbourEntityIds,
          childEntityIds,
          parentEntity
        ),
        "voxel interaction selector"
      );

      if (success) {
        try this.decodeToBoolAndBytes(returnData) returns (bool changedCACenterEntityId, bytes memory entityEventData) {
          if (changedCenterEntityId == 0 && changedCACenterEntityId) {
            changedCenterEntityId = caInteractEntity;
          }

          if (centerEntityEventData.length == 0 && entityEventData.length != 0) {
            centerEntityEventData = entityEventData;
          }
        } catch {}
      }
    }

    return (changedCenterEntityId, centerEntityEventData);
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
    beforeRunInteraction(centerEntityId, neighbourEntityIds);

    // Run interaction logic
    // Center Interaction
    (bytes32 changedCenterEntityId, bytes memory centerEntityEventData) = runEventHandler(
      interactionSelector,
      voxelTypeId,
      caInteractEntity,
      caNeighbourEntityIds,
      childEntityIds,
      parentEntity
    );

    // Neighbour Interactions
    (bytes32[] memory changedNeighbourEntities, bytes[] memory neighbourEntitiesEventData) = runNeighbourEventHandlers(
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
