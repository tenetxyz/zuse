// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { VoxelEntity } from "@tenet-utils/src/Types.sol";
import { hasEntity } from "@tenet-utils/src/Utils.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { NUM_VOXEL_NEIGHBOURS, MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH } from "@tenet-utils/src/Constants.sol";
import { Position, PositionData } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { VoxelType, VoxelTypeData } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { VoxelActivated, VoxelActivatedData } from "@tenet-base-world/src/codegen/tables/VoxelActivated.sol";
import { getEntityAtCoord, calculateChildCoords, calculateParentCoord } from "@tenet-base-world/src/Utils.sol";
import { runInteraction, enterWorld, exitWorld, activateVoxel, moveLayer } from "@tenet-base-ca/src/CallUtils.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";

abstract contract RunCASystem is System {
  function enterCA(
    address caAddress,
    VoxelEntity memory entity,
    bytes32 voxelTypeId,
    bytes4 mindSelector,
    VoxelCoord memory coord
  ) public virtual {
    bytes32[] memory neighbourEntities = IWorld(_world()).calculateNeighbourEntities(entity);
    bytes32[] memory childEntityIds = IWorld(_world()).calculateChildEntities(entity);
    bytes32 parentEntity = IWorld(_world()).calculateParentEntity(entity);
    enterWorld(caAddress, voxelTypeId, mindSelector, coord, entity.entityId, neighbourEntities, childEntityIds, parentEntity);
  }

  function moveCA(
    address caAddress,
    VoxelEntity memory newEntity,
    bytes32 voxelTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord
  ) public virtual {
    bytes32[] memory neighbourEntities = IWorld(_world()).calculateNeighbourEntities(newEntity);
    bytes32[] memory childEntityIds = IWorld(_world()).calculateChildEntities(newEntity);
    bytes32 parentEntity = IWorld(_world()).calculateParentEntity(newEntity);
    moveLayer(caAddress, voxelTypeId, oldCoord, newCoord, newEntity.entityId, neighbourEntities, childEntityIds, parentEntity);
  }

  function exitCA(
    address caAddress,
    VoxelEntity memory entity,
    bytes32 voxelTypeId,
    VoxelCoord memory coord
  ) public virtual {
    bytes32[] memory neighbourEntities = IWorld(_world()).calculateNeighbourEntities(entity);
    bytes32[] memory childEntityIds = IWorld(_world()).calculateChildEntities(entity);
    bytes32 parentEntity = IWorld(_world()).calculateParentEntity(entity);
    exitWorld(caAddress, voxelTypeId, coord, entity.entityId, neighbourEntities, childEntityIds, parentEntity);
  }

  function activateCA(address caAddress, VoxelEntity memory entity) public virtual {
    bytes memory returnData = activateVoxel(caAddress, entity.entityId);
    string memory activateStr = abi.decode(returnData, (string));
    VoxelActivated.emitEphemeral(tx.origin, VoxelActivatedData({ scale: entity.scale, entity: entity.entityId, message: activateStr }));
  }

  function runCA(address caAddress, VoxelEntity memory entity, bytes4 interactionSelector) public virtual {
    uint32 scale = entity.scale;
    bytes32 entityId = entity.entityId;
    bytes32[] memory centerEntitiesToCheckStack = new bytes32[](MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH);
    uint256 centerEntitiesToCheckStackIdx = 0;
    uint256 useStackIdx = 0;

    // start with the center entity
    centerEntitiesToCheckStack[centerEntitiesToCheckStackIdx] = entityId;
    useStackIdx = centerEntitiesToCheckStackIdx;

    // Keep looping until there is no neighbour to process or we reached max depth
    // TODO: We need to call parent CA's as well after we're done going over this CA
    bytes4 useInteractionSelector = interactionSelector;

    while (useStackIdx < MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH) {
      bytes32 useCenterEntityId = centerEntitiesToCheckStack[useStackIdx];
      VoxelEntity memory centerEntity = VoxelEntity({ entityId: useCenterEntityId, scale: scale });
      bytes32[] memory useNeighbourEntities = IWorld(_world()).calculateNeighbourEntities(centerEntity);
      bytes32[] memory childEntityIds = IWorld(_world()).calculateChildEntities(centerEntity);
      bytes32 parentEntity = IWorld(_world()).calculateParentEntity(centerEntity);
      // if (!hasEntity(useNeighbourEntities)) {
      //   // if no neighbours, then we don't run any voxel interactions because there would be none
      //   break;
      // }

      // Run interaction logic
      bytes memory returnData = runInteraction(
        caAddress,
        useInteractionSelector,
        useCenterEntityId,
        useNeighbourEntities,
        childEntityIds,
        parentEntity
      );
      bytes32[] memory changedEntities = abi.decode(returnData, (bytes32[]));
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

      // Run the CA for each parent now

      CAVoxelTypeData memory changedEntityVoxelType = CAVoxelType.get(IStore(caAddress), _world(), changedEntity);
      // Update VoxelType
      VoxelType.set(scale, changedEntity, changedEntityVoxelType.voxelTypeId, changedEntityVoxelType.voxelVariantId);
      // TODO: Do we need this?
      // Position should not change of the entity
      // Position.set(scale, changedEntities[i], coord.x, coord.y, coord.z);
    }
  }
}