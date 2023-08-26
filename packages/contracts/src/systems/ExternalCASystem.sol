// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../Types.sol";
import { hasEntity } from "@tenet-utils/src/Utils.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { NUM_VOXEL_NEIGHBOURS, MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH } from "../Constants.sol";
import { Position, PositionData, VoxelType, VoxelTypeData, VoxelActivated, VoxelActivatedData } from "@tenet-contracts/src/codegen/Tables.sol";
import { getEntityAtCoord, calculateChildCoords, calculateParentCoord } from "../Utils.sol";
import { runInteraction, enterWorld, exitWorld, activateVoxel, moveLayer } from "@tenet-base-ca/src/CallUtils.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";

contract ExternalCASystem is System {
  function getVoxelTypeId(uint32 scale, bytes32 entity) public view returns (bytes32) {
    return VoxelType.getVoxelTypeId(scale, entity);
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
      VoxelCoord[] memory eightBlockVoxelCoords = calculateChildCoords(2, baseVoxelCoord);

      for (uint8 i = 0; i < 8; i++) {
        // filter for the ones with scale-1
        bytes32 childEntityAtPosition = getEntityAtCoord(scale - 1, eightBlockVoxelCoords[i]);

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
}