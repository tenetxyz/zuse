// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../Types.sol";
import { OwnedBy, Position, PositionTableId, VoxelType, VoxelTypeData, VoxelTypeRegistry } from "@tenet-contracts/src/codegen/Tables.sol";
import { AirID } from "./voxels/AirVoxelSystem.sol";
import { addressToEntityKey, enterVoxelIntoWorld, updateVoxelVariant, increaseVoxelTypeSpawnCount } from "../Utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";

contract BuildSystem is System {
  function buildVoxelType(VoxelTypeData memory voxelType, VoxelCoord memory coord) public returns (bytes32) {
    address callerAddress = msg.sender;

    address caAddress = VoxelTypeRegistry.get(voxelType);
    // read ChildTypes in caAddress
    level = 0
    if childTypes empty:
      bytes32 newEntity = world.createNewEntity();
      newVoxelType = caAddress.enterWorld(voxelType, coord, entity);
      Position.set(level, entity, coord);
      VoxelType.set(level, entity, newVoxelType);

      while changedEntities:
        childEntityIds = []
        parentEntityIds = []calc based on grid

        changedEntities = caAddress.runInteraction(
          entity,
          neighbourEntityIds,
          childEntityIds,
          parentEntityIds
        );

      update VoxelType by reading caAddress voxel type table


    return newEntity;
  }
}
