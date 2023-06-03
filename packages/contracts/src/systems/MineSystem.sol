// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../types.sol";
import { OwnedBy, Position, PositionTableId, Item } from "../codegen/Tables.sol";
import { AirID, WaterID } from "../prototypes/Blocks.sol";
import { addressToEntityKey } from "../utils.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { Occurrence } from "../codegen/Tables.sol";
import { console } from "forge-std/console.sol";

contract MineSystem is System {

  function mine(VoxelCoord memory coord, bytes32 blockType) public returns (bytes32) {
    require(blockType != AirID, "can not mine air");
    require(blockType != WaterID, "can not mine water");
    require(coord.y < 256 && coord.y >= -63, "out of chunk bounds");

    // TODO: check claim in chunk

    // Check ECS blocks at coord
    bytes32[] memory entitiesAtPosition = getKeysWithValue(PositionTableId, Position.encode(coord.x, coord.y, coord.z));

    bytes32 entity;

    if (entitiesAtPosition.length == 0) {
      // If there is no entity at this position, try mining the terrain block at this position
       (bool success, bytes memory occurrence) = staticcallFunctionSelector(
         Occurrence.get(blockType),
         abi.encode(coord)
       );
       require(
         success && occurrence.length > 0 && abi.decode(occurrence, (bytes32)) == blockType,
         "invalid terrain block type"
       );

      // Create an ECS block from this coord's terrain block
      entity = getUniqueEntity();
      Item.set(entity, blockType);

      // Place an air block at this position
      bytes32 airEntity = getUniqueEntity();
      Item.set(airEntity, AirID);
      Position.set(airEntity, coord.x, coord.y, coord.z);
    } else {
      // Else, mine the non-air entity block at this position
      for (uint256 i; i < entitiesAtPosition.length; i++) {
        if (Item.get(entitiesAtPosition[i]) == blockType) entity = entitiesAtPosition[i];
      }
      require(entity != 0, "invalid block type");
      Position.deleteRecord(entity);
    }

    OwnedBy.set(entity, addressToEntityKey(_msgSender()));

    return entity;
  }

  function staticcallFunctionSelector(bytes4 functionPointer, bytes memory args) private view returns (bool, bytes memory){
    return _world().staticcall(bytes.concat(functionPointer, args));
  }
}