// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../Types.sol";
import { Position, PositionData, PositionTableId, VoxelType, VoxelTypeData, VoxelTypeRegistry } from "@tenet-contracts/src/codegen/Tables.sol";
import { AirID } from "./voxels/AirVoxelSystem.sol";
import { addressToEntityKey, enterVoxelIntoWorld, updateVoxelVariant, increaseVoxelTypeSpawnCount, getPositionAtDirection } from "../Utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { BlockDirection } from "@tenet-contracts/src/Types.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

contract MoveSystem is System {
  // tries to move the voxel in a direction as long as that direction is air
  // returns true if the move was successful
  function tryMove(bytes32 entity, BlockDirection blockDirection) public returns (bool) {
    PositionData memory position = Position.get(entity);
    VoxelCoord memory coord = VoxelCoord(position.x, position.y, position.z);
    VoxelCoord memory adjacentCoord = getPositionAtDirection(coord, blockDirection);

    // Validate that we can move to the adjacent coord
    bytes32[] memory entitiesAtPosition = getKeysWithValue(
      PositionTableId,
      Position.encode(adjacentCoord.x, adjacentCoord.y, adjacentCoord.z)
    );
    require(entitiesAtPosition.length <= 1, "more than one voxel found at next position");
    if (entitiesAtPosition.length == 1) {
      // if we are moving to a spot that is NOT air, then prohibit this move.
      bytes32 voxelEntity = entitiesAtPosition[0];
      if (VoxelType.get(voxelEntity).voxelTypeId != AirID) {
        return false;
      }
    }

    // we can move here to that spot
    Position.set(entity, adjacentCoord.x, adjacentCoord.y, adjacentCoord.z);
    return true;
  }
}
