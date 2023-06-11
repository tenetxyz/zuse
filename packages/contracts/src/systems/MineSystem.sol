// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../types.sol";
import { OwnedBy, Position, PositionTableId, VoxelType, Extension, ExtensionTableId } from "../codegen/Tables.sol";
import { AirID, WaterID } from "../prototypes/Voxels.sol";
import { addressToEntityKey } from "../utils.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { Occurrence } from "../codegen/Tables.sol";
import { console } from "forge-std/console.sol";

contract MineSystem is System {

  function mine(VoxelCoord memory coord, bytes32 voxelType) public returns (bytes32) {
    require(voxelType != AirID, "can not mine air");
    require(voxelType != WaterID, "can not mine water");
    require(coord.y < 256 && coord.y >= -63, "out of chunk bounds");

    // TODO: check claim in chunk

    // Check ECS voxels at coord
    bytes32[] memory entitiesAtPosition = getKeysWithValue(PositionTableId, Position.encode(coord.x, coord.y, coord.z));

    bytes32 entity;

    if (entitiesAtPosition.length == 0) {
      // If there is no entity at this position, try mining the terrain voxel at this position
       (bool success, bytes memory occurrence) = staticcallFunctionSelector(
         Occurrence.get(voxelType),
         abi.encode(coord)
       );
       require(
         success && occurrence.length > 0 && abi.decode(occurrence, (bytes32)) == voxelType,
         "invalid terrain voxel type"
       );

      // Create an ECS voxel from this coord's terrain voxel
      entity = getUniqueEntity();
      VoxelType.set(entity, voxelType);

      // Place an air voxel at this position
      bytes32 airEntity = getUniqueEntity();
      VoxelType.set(airEntity, AirID);
      Position.set(airEntity, coord.x, coord.y, coord.z);
    } else {
      // Else, mine the non-air entity voxel at this position
      for (uint256 i; i < entitiesAtPosition.length; i++) {
        if (VoxelType.get(entitiesAtPosition[i]) == voxelType) entity = entitiesAtPosition[i];
      }
      require(entity != 0, "invalid voxel type");
      Position.deleteRecord(entity);
    }

    OwnedBy.set(entity, addressToEntityKey(_msgSender()));

    // Go over all registered extensions and call them
    // TODO: Should filter which ones to call based on key
    // Get all extensions
    bytes32[][] memory extensions = getKeysInTable(ExtensionTableId);
    // Get all values corresponding to those keys
    bytes32 centerEntityId = entity;
    bytes32[] memory neighbourEntityIds = new bytes32[](6);

    for (uint256 i; i < extensions.length; i++) {
        // Call the extension
        bytes16 extensionNamespace = bytes16(extensions[i][0]);
        bytes4 eventHandler = Extension.get(extensionNamespace);
        (bool success, bytes memory returnData) = _world().call(abi.encodeWithSelector(eventHandler, centerEntityId, neighbourEntityIds));
        // TODO: Add error handling
    }

    return entity;
  }

  function staticcallFunctionSelector(bytes4 functionPointer, bytes memory args) private view returns (bool, bytes memory){
    return _world().staticcall(bytes.concat(functionPointer, args));
  }
}