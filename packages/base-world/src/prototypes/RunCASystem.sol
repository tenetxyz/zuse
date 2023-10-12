// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelEntity, EntityEventData } from "@tenet-utils/src/Types.sol";
import { hasEntity } from "@tenet-utils/src/Utils.sol";
import { KeysInTable } from "@latticexyz/world/src/modules/keysintable/tables/KeysInTable.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { Interactions, InteractionsTableId } from "@tenet-base-world/src/codegen/tables/Interactions.sol";
import { MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH, MAX_UNIQUE_ENTITY_INTERACTIONS_RUN } from "@tenet-utils/src/Constants.sol";
import { Position, PositionData } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { VoxelType, VoxelTypeData } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { VoxelActivated, VoxelActivatedData } from "@tenet-base-world/src/codegen/tables/VoxelActivated.sol";
import { getEntityAtCoord, calculateChildCoords, calculateParentCoord } from "@tenet-base-world/src/Utils.sol";
import { runInteraction, enterWorld, exitWorld, activateVoxel, moveLayer } from "@tenet-base-ca/src/CallUtils.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { console } from "forge-std/console.sol";

abstract contract RunCASystem is System {
  function enterCA(
    address caAddress,
    VoxelEntity memory entity,
    bytes32 voxelTypeId,
    bytes4 mindSelector,
    VoxelCoord memory coord
  ) public virtual {
    (bytes32[] memory neighbourEntities, ) = IWorld(_world()).calculateNeighbourEntities(entity);
    bytes32[] memory childEntityIds = IWorld(_world()).calculateChildEntities(entity);
    bytes32 parentEntity = IWorld(_world()).calculateParentEntity(entity);
    enterWorld(
      caAddress,
      voxelTypeId,
      mindSelector,
      coord,
      entity.entityId,
      neighbourEntities,
      childEntityIds,
      parentEntity
    );
  }

  function moveCA(
    address caAddress,
    VoxelEntity memory newEntity,
    bytes32 voxelTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord
  ) public virtual {
    (bytes32[] memory neighbourEntities, ) = IWorld(_world()).calculateNeighbourEntities(newEntity);
    bytes32[] memory childEntityIds = IWorld(_world()).calculateChildEntities(newEntity);
    bytes32 parentEntity = IWorld(_world()).calculateParentEntity(newEntity);
    moveLayer(
      caAddress,
      voxelTypeId,
      oldCoord,
      newCoord,
      newEntity.entityId,
      neighbourEntities,
      childEntityIds,
      parentEntity
    );
  }

  function exitCA(
    address caAddress,
    VoxelEntity memory entity,
    bytes32 voxelTypeId,
    VoxelCoord memory coord
  ) public virtual {
    (bytes32[] memory neighbourEntities, ) = IWorld(_world()).calculateNeighbourEntities(entity);
    bytes32[] memory childEntityIds = IWorld(_world()).calculateChildEntities(entity);
    bytes32 parentEntity = IWorld(_world()).calculateParentEntity(entity);
    exitWorld(caAddress, voxelTypeId, coord, entity.entityId, neighbourEntities, childEntityIds, parentEntity);
  }

  function activateCA(address caAddress, VoxelEntity memory entity) public virtual {
    bytes memory returnData = activateVoxel(caAddress, entity.entityId);
    string memory activateStr = abi.decode(returnData, (string));
    VoxelActivated.emitEphemeral(
      tx.origin,
      VoxelActivatedData({ scale: entity.scale, entity: entity.entityId, message: activateStr })
    );
  }

  function beforeRunInteraction(VoxelEntity memory entity) internal virtual {}

  function runInteractionWrapper(
    address caAddress,
    uint32 scale,
    bytes32 centerEntityId,
    bytes4 useInteractionSelector
  ) internal returns (bytes32[] memory, EntityEventData[] memory) {
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

    EntityEventData[] memory allEntitiesEventData = new EntityEventData[](entitiesEventData.length);

    for (uint256 i; i < entitiesEventData.length; i++) {
      if (entitiesEventData[i].length == 0) {
        continue;
      }

      allEntitiesEventData[i] = EntityEventData({
        entity: VoxelEntity({ scale: scale, entityId: i == 0 ? centerEntityId : neighbourEntities[i - 1] }),
        eventData: entitiesEventData[i]
      });
    }

    return (changedEntities, allEntitiesEventData);
  }

  function runCA(
    address caAddress,
    VoxelEntity memory entity,
    bytes4 interactionSelector
  ) public virtual returns (EntityEventData[] memory) {
    if (!Interactions.get(entity.scale, entity.entityId)) {
      console.log("interaction unique entity");
      console.logBytes32(entity.entityId);
      uint256 numInteractionsRan = KeysInTable.lengthKeys0(InteractionsTableId);
      console.logUint(numInteractionsRan);
      if (numInteractionsRan + 1 > MAX_UNIQUE_ENTITY_INTERACTIONS_RUN) {
        return new EntityEventData[](0);
      }
      Interactions.set(entity.scale, entity.entityId, true);
    }

    bytes32[] memory centerEntitiesToCheckStack = new bytes32[](MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH);
    EntityEventData[] memory allEntitiesEventData = new EntityEventData[](MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH);
    uint256 centerEntitiesToCheckStackIdx = 0;
    uint256 entitesEventDataIdx = 0;
    uint256 useStackIdx = 0;

    // start with the center entity
    centerEntitiesToCheckStack[centerEntitiesToCheckStackIdx] = entity.entityId;
    useStackIdx = centerEntitiesToCheckStackIdx;

    // Keep looping until there is no neighbour to process or we reached max depth
    bytes4 useInteractionSelector = interactionSelector;

    while (useStackIdx < MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH) {
      bytes32 useCenterEntityId = centerEntitiesToCheckStack[useStackIdx];

      {
        (bytes32[] memory changedEntities, EntityEventData[] memory entitiesEventData) = runInteractionWrapper(
          caAddress,
          entity.scale,
          useCenterEntityId,
          useInteractionSelector
        );

        useInteractionSelector = bytes4(0); // Only use the interaction selector for the first call, then use the Mind

        // If there are changed entities, we want to run voxel interactions again but with this new neighbour as the center
        for (uint256 i; i < changedEntities.length; i++) {
          if (uint256(changedEntities[i]) != 0) {
            centerEntitiesToCheckStackIdx++;
            require(
              centerEntitiesToCheckStackIdx < MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH,
              "VoxelInteractionSystem: Reached max depth"
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
          require(entitesEventDataIdx < MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH, "VoxelInteractionSystem: Reached max depth");
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

    // Update VoxelType and Position at this level to match the CA
    // Go through all the center entities that had an event run, and run its variant selector
    for (uint256 i = 0; i <= centerEntitiesToCheckStackIdx; i++) {
      bytes32 changedEntity = centerEntitiesToCheckStack[i];
      if (changedEntity == 0) {
        continue;
      }

      CAVoxelTypeData memory changedEntityVoxelType = CAVoxelType.get(IStore(caAddress), _world(), changedEntity);
      VoxelType.set(
        entity.scale,
        changedEntity,
        changedEntityVoxelType.voxelTypeId,
        changedEntityVoxelType.voxelVariantId
      );
    }

    return allEntitiesEventData;
  }
}
