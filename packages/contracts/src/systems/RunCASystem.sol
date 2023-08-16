// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../Types.sol";
import { hasEntity } from "@tenet-utils/src/Utils.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { CABodyType, CABodyTypeData } from "@tenet-base-ca/src/codegen/tables/CABodyType.sol";
import { NUM_VOXEL_NEIGHBOURS, MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH } from "../Constants.sol";
import { Position, PositionData, BodyType, VoxelActivated, VoxelActivatedData } from "@tenet-contracts/src/codegen/Tables.sol";
import { getEntityAtCoord, calculateChildCoords, calculateParentCoord } from "../Utils.sol";
import { runInteraction, enterWorld, exitWorld, activateBody, moveLayer } from "@tenet-base-ca/src/CallUtils.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";

contract RunCASystem is System {
  function getBodyTypeId(uint32 scale, bytes32 entity) public view returns (bytes32) {
    return BodyType.getBodyTypeId(scale, entity);
  }

  function enterCA(
    address caAddress,
    uint32 scale,
    bytes32 bodyTypeId,
    bytes4 mindSelector,
    VoxelCoord memory coord,
    bytes32 entity
  ) public {
    bytes32[] memory neighbourEntities = calculateNeighbourEntities(scale, entity);
    bytes32[] memory childEntityIds = calculateChildEntities(scale, entity);
    bytes32 parentEntity = calculateParentEntity(scale, entity);
    enterWorld(caAddress, bodyTypeId, mindSelector, coord, entity, neighbourEntities, childEntityIds, parentEntity);
  }

  function moveCA(
    address caAddress,
    uint32 scale,
    bytes32 bodyTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    bytes32 newEntity
  ) public {
    bytes32[] memory neighbourEntities = calculateNeighbourEntities(scale, newEntity);
    bytes32[] memory childEntityIds = calculateChildEntities(scale, newEntity);
    bytes32 parentEntity = calculateParentEntity(scale, newEntity);
    moveLayer(caAddress, bodyTypeId, oldCoord, newCoord, newEntity, neighbourEntities, childEntityIds, parentEntity);
  }

  function exitCA(address caAddress, uint32 scale, bytes32 bodyTypeId, VoxelCoord memory coord, bytes32 entity) public {
    bytes32[] memory neighbourEntities = calculateNeighbourEntities(scale, entity);
    bytes32[] memory childEntityIds = calculateChildEntities(scale, entity);
    bytes32 parentEntity = calculateParentEntity(scale, entity);
    exitWorld(caAddress, bodyTypeId, coord, entity, neighbourEntities, childEntityIds, parentEntity);
  }

  function activateCA(address caAddress, uint32 scale, bytes32 entity) public {
    bytes memory returnData = activateBody(caAddress, entity);
    string memory activateStr = abi.decode(returnData, (string));
    VoxelActivated.emitEphemeral(tx.origin, VoxelActivatedData({ scale: scale, entity: entity, message: activateStr }));
  }

  function calculateNeighbourEntities(uint32 scale, bytes32 centerEntity) public view returns (bytes32[] memory) {
    int8[NUM_VOXEL_NEIGHBOURS * 3] memory NEIGHBOUR_COORD_OFFSETS = [
      int8(0),
      int8(0),
      int8(1),
      // ----
      int8(0),
      int8(0),
      int8(-1),
      // ----
      int8(1),
      int8(0),
      int8(0),
      // ----
      int8(-1),
      int8(0),
      int8(0),
      // ----
      int8(1),
      int8(0),
      int8(1),
      // ----
      int8(1),
      int8(0),
      int8(-1),
      // ----
      int8(-1),
      int8(0),
      int8(1),
      // ----
      int8(-1),
      int8(0),
      int8(-1),
      // ----
      int8(0),
      int8(1),
      int8(0),
      // ----
      int8(0),
      int8(-1),
      int8(0)
    ];

    bytes32[] memory centerNeighbourEntities = new bytes32[](NUM_VOXEL_NEIGHBOURS);
    PositionData memory baseCoord = Position.get(scale, centerEntity);

    for (uint8 i = 0; i < centerNeighbourEntities.length; i++) {
      VoxelCoord memory neighbouringCoord = VoxelCoord(
        baseCoord.x + NEIGHBOUR_COORD_OFFSETS[i * 3],
        baseCoord.y + NEIGHBOUR_COORD_OFFSETS[i * 3 + 1],
        baseCoord.z + NEIGHBOUR_COORD_OFFSETS[i * 3 + 2]
      );

      bytes32 neighbourEntity = getEntityAtCoord(scale, neighbouringCoord);

      if (uint256(neighbourEntity) != 0) {
        // entity exists so add it to the list
        centerNeighbourEntities[i] = neighbourEntity;
      } else {
        // no entity exists so add air
        // TODO: How do we deal with entities not created yet, but still in the world due to terrain generation
        centerNeighbourEntities[i] = 0;
      }
    }

    return centerNeighbourEntities;
  }

  // TODO: Make this general by using cube root
  function calculateChildEntities(uint32 scale, bytes32 entity) public view returns (bytes32[] memory) {
    if (scale >= 2) {
      bytes32[] memory childEntities = new bytes32[](8);
      PositionData memory baseCoord = Position.get(scale, entity);
      VoxelCoord memory baseVoxelCoord = VoxelCoord({ x: baseCoord.x, y: baseCoord.y, z: baseCoord.z });
      VoxelCoord[] memory eightBlockBodyCoords = calculateChildCoords(2, baseVoxelCoord);

      for (uint8 i = 0; i < 8; i++) {
        // filter for the ones with scale-1
        bytes32 childEntityAtPosition = getEntityAtCoord(scale - 1, eightBlockBodyCoords[i]);

        // if (childEntityAtPosition == 0) {
        //   revert("found no child entity");
        // }

        childEntities[i] = childEntityAtPosition;
      }

      return childEntities;
    }

    return new bytes32[](0);
  }

  // TODO: Make this general by using cube root
  function calculateParentEntity(uint32 scale, bytes32 entity) public view returns (bytes32) {
    bytes32 parentEntity;

    PositionData memory baseCoord = Position.get(scale, entity);
    VoxelCoord memory baseVoxelCoord = VoxelCoord({ x: baseCoord.x, y: baseCoord.y, z: baseCoord.z });
    VoxelCoord memory parentVoxelCoord = calculateParentCoord(2, baseVoxelCoord);
    parentEntity = getEntityAtCoord(scale + 1, parentVoxelCoord);

    return parentEntity;
  }

  function runCA(address caAddress, uint32 scale, bytes32 entity, bytes4 interactionSelector) public {
    bytes32[] memory centerEntitiesToCheckStack = new bytes32[](MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH);
    uint256 centerEntitiesToCheckStackIdx = 0;
    uint256 useStackIdx = 0;

    // start with the center entity
    centerEntitiesToCheckStack[centerEntitiesToCheckStackIdx] = entity;
    useStackIdx = centerEntitiesToCheckStackIdx;

    // Keep looping until there is no neighbour to process or we reached max depth
    // TODO: We need to call parent CA's as well after we're done going over this CA
    bytes4 useInteractionSelector = interactionSelector;

    while (useStackIdx < MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH) {
      bytes32 useCenterEntityId = centerEntitiesToCheckStack[useStackIdx];
      bytes32[] memory useNeighbourEntities = calculateNeighbourEntities(scale, useCenterEntityId);
      bytes32[] memory childEntityIds = calculateChildEntities(scale, useCenterEntityId);
      bytes32 parentEntity = calculateParentEntity(scale, useCenterEntityId);
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

    // Update BodyType and Position at this level to match the CA
    // Go through all the center entities that had an event run, and run its variant selector
    for (uint256 i = 0; i <= centerEntitiesToCheckStackIdx; i++) {
      bytes32 changedEntity = centerEntitiesToCheckStack[i];
      if (changedEntity == 0) {
        continue;
      }

      // Run the CA for each parent now

      CABodyTypeData memory changedEntityBodyType = CABodyType.get(IStore(caAddress), _world(), changedEntity);
      // Update BodyType
      BodyType.set(scale, changedEntity, changedEntityBodyType.bodyTypeId, changedEntityBodyType.bodyVariantId);
    }
  }
}
