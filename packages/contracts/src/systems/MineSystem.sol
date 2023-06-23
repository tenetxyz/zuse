// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import {systemNamespace} from "@latticexyz/world/src/Utils.sol";
import { VoxelCoord } from "../types.sol";
import { OwnedBy, Position, PositionTableId, VoxelType, VoxelTypeData, VoxelTypeRegistry } from "../codegen/Tables.sol";
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

    bytes32 voxelToMine;
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
      bytes16 namespace = systemNamespace(address(this));

      // Create an ECS voxel from this coord's terrain voxel
      voxelToMine = getUniqueEntity();
      {
        // get block selector from VoxelTypeRegistry
        bytes4 blockSelector = VoxelTypeRegistry.get(namespace, voxelType);
        // call blockSelector
        (bool blockSuccess, bytes memory blockVoxelVariant) = staticcallFunctionSelector(
          blockSelector,
          abi.encode(voxelToMine)
        );
        require(blockSuccess, "failed to get block voxel type");
        VoxelTypeData memory blockVoxelType = abi.decode(blockVoxelVariant, (VoxelTypeData));
        blockVoxelType.namespace = namespace;
        blockVoxelType.voxelType = voxelType;

        VoxelType.set(voxelToMine, blockVoxelType);
      }
    } else {
      // Else, mine the non-air entity voxel at this position
      for (uint256 i; i < entitiesAtPosition.length; i++) {
        if (VoxelType.get(entitiesAtPosition[i]).voxelType == voxelType){
          voxelToMine = entitiesAtPosition[i];
        }
      }
      require(voxelToMine != 0, "We found no voxels at that position that match the voxel type");
      Position.deleteRecord(voxelToMine);

      // TODO: should reset component values
    }

    // Place an air voxel at this position
    airEntity = getUniqueEntity();
    {
      // get Air selector from VoxelTypeRegistry
      bytes4 airSelector = VoxelTypeRegistry.get(namespace, AirID);
      // call airSelector
      (bool airSuccess, bytes memory airVoxelVariant) = staticcallFunctionSelector(
        airSelector,
        abi.encode(airEntity)
      );
      require(airSuccess, "failed to get air voxel type");
      VoxelTypeData memory airVoxelType = abi.decode(airVoxelVariant, (VoxelTypeData));
      airVoxelType.namespace = namespace;
      airVoxelType.voxelType = AirID;
      VoxelType.set(airEntity, airVoxelType);
    }

    Position.set(airEntity, coord.x, coord.y, coord.z);

    OwnedBy.set(voxelToMine, addressToEntityKey(_msgSender()));
    // Since numUniqueVoxelTypesIOwn is quadratic in gas (based on how many voxels you own), running this function could use up all your gas. So it's commented
//    require(IWorld(_world()).tenet_GiftVoxelSystem_numUniqueVoxelTypesIOwn() <= 36, "you can only own 36 voxel types at a time");

    // Run voxel interaction logic
    IWorld(_world()).tenet_VoxInteractSys_runInteractionSystems(airEntity);

    return voxelToMine;
  }

  function staticcallFunctionSelector(bytes4 functionPointer, bytes memory args) private view returns (bool, bytes memory){
    return _world().staticcall(bytes.concat(functionPointer, args));
  }
}