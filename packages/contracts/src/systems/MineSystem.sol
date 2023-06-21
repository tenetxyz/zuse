// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../types.sol";
import { OwnedBy, Position, PositionTableId, VoxelType, Extension, ExtensionTableId } from "../codegen/Tables.sol";
import { AirID, WaterID } from "../prototypes/Voxels.sol";
import { addressToEntityKey, getEntitiesAtCoord } from "../utils.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { Occurrence } from "../codegen/Tables.sol";
import { console } from "forge-std/console.sol";
import { CHUNK_MAX_Y, CHUNK_MIN_Y } from "../Constants.sol";

contract MineSystem is System {

  function mine(VoxelCoord memory coord, bytes32 voxelType) public returns (bytes32) {
    require(voxelType != AirID, "can not mine air");
    require(voxelType != WaterID, "can not mine water");
    require(coord.y <= CHUNK_MAX_Y && coord.y >= CHUNK_MIN_Y, "out of chunk bounds");

    // TODO: check claim in chunk

    // Check ECS blocks at coord
    bytes32[] memory entitiesAtPosition = getEntitiesAtCoord(coord);

    bytes32 entity;
    bytes32 airEntity;

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
    } else {
      // Else, mine the non-air entity voxel at this position
      for (uint256 i; i < entitiesAtPosition.length; i++) {
        if (VoxelType.get(entitiesAtPosition[i]) == voxelType) entity = entitiesAtPosition[i];
      }
      require(entity != 0, "invalid voxel type");
      Position.deleteRecord(entity);
    }

    // Place an air voxel at this position
    airEntity = getUniqueEntity();
    VoxelType.set(airEntity, AirID);
    Position.set(airEntity, coord.x, coord.y, coord.z);

    OwnedBy.set(entity, addressToEntityKey(_msgSender()));
    require(IWorld(_world()).tenet_GiftVoxelSystem_numUniqueVoxelTypesIOwn() <= 36, "you can only own 36 voxel types at a time");

    // Run voxel interaction logic
    IWorld(_world()).tenet_VoxelInteraction_runInteractionSystems(airEntity);

    return entity;
  }

  function staticcallFunctionSelector(bytes4 functionPointer, bytes memory args) private view returns (bool, bytes memory){
    return _world().staticcall(bytes.concat(functionPointer, args));
  }
}