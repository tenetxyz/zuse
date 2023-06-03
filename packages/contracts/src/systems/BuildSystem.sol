// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../types.sol";
import { OwnedBy, Position, PositionTableId, Item } from "../codegen/Tables.sol";
import { AirID } from "../prototypes/Blocks.sol";
import { addressToEntityKey } from "../utils.sol";

contract BuildSystem is System {

  function build(bytes32 blockEntity, VoxelCoord memory coord) public returns (bytes32) {

    // Require block to be owned by caller
    require(OwnedBy.get(blockEntity) == addressToEntityKey(_msgSender()), "block is not owned by player");

    // Require no other ECS blocks at this position except Air
    bytes32[] memory entitiesAtPosition = getKeysWithValue(PositionTableId, Position.encode(coord.x, coord.y, coord.z));
    require(entitiesAtPosition.length == 0 || entitiesAtPosition.length == 1, "can not built at non-empty coord");
    if (entitiesAtPosition.length == 1) {
      require(Item.get(entitiesAtPosition[0]) == AirID, "can not built at non-empty coord (2)");
    }

    // TODO: check claim in chunk

    // Remove block from inventory and place it in the world
    OwnedBy.deleteRecord(blockEntity);
    Position.set(blockEntity, coord.x, coord.y, coord.z);

    return blockEntity;
  }

}