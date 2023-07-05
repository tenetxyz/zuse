// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../Types.sol";
import { OwnedBy, Position, PositionTableId, VoxelType, VoxelTypeData, VoxelVariantsData, VoxelTypeRegistry } from "../codegen/Tables.sol";
import { AirID } from "../prototypes/Voxels.sol";
import { addressToEntityKey, updateVoxelVariant, increaseVoxelTypeSpawnCount, getEntitiesAtCoord } from "../Utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { IWorld } from "../codegen/world/IWorld.sol";

contract GravitySystem is System {
  // function checkIfShouldFall(VoxelVariantsData memory voxelTop, VoxelVariantsData voxelBottom) public returns (bool) {
  //   // check if the mass of the voxel is greater than the mass of the voxel below it
  //   return voxelTop.mass > voxelBottom.mass;
  // }

  function runGravity(bytes32 entity) public {
    //  1) check if the block below this block is lighter than this block, if so, move this block down and break that block
    // 2) check if the block above this block is heavier than this block, if so, break this block and move that block down
  }
}
