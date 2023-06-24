// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelVariantsKey } from "../types.sol";
import { OwnedBy, Position, PositionTableId, VoxelType, VoxelTypeData, VoxelTypeRegistry } from "../codegen/Tables.sol";
import { AirID, WaterID } from "../prototypes/Voxels.sol";
import { addressToEntityKey, getEntitiesAtCoord } from "../utils.sol";
import { Utils } from "@latticexyz/world/src/Utils.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { Occurrence } from "../codegen/Tables.sol";
import { console } from "forge-std/console.sol";
import { CHUNK_MAX_Y, CHUNK_MIN_Y } from "../Constants.sol";

contract MineSystem is System {

  function mine(VoxelCoord memory coord, bytes16 voxelTypeNamespace, bytes32 voxelTypeId, bytes16 voxelVariantNamespace, bytes32 voxelVariantId) public returns (bytes32) {
    require(voxelTypeId != AirID, "can not mine air");
    require(voxelTypeId != WaterID, "can not mine water");
    require(coord.y <= CHUNK_MAX_Y && coord.y >= CHUNK_MIN_Y, "out of chunk bounds");

    // Check ECS blocks at coord
    bytes32[] memory entitiesAtPosition = getEntitiesAtCoord(coord);

    bytes32 voxelToMine;
    bytes32 airEntity;

    // Create an ECS voxel from this coord's terrain voxel
    bytes16 namespace = Utils.systemNamespace();

    if (entitiesAtPosition.length == 0) {
        // If there is no entity at this position, try mining the terrain voxel at this position
       (bool success, bytes memory occurrence) = staticcallFunctionSelector(
         Occurrence.get(voxelTypeId),
         abi.encode(coord)
       );
       require(
         success && occurrence.length > 0,
         "invalid terrain voxel type"
       );
       VoxelVariantsKey memory occurenceVoxelKey = abi.decode(occurrence, (VoxelVariantsKey));
      require(
        occurenceVoxelKey.namespace == voxelVariantNamespace && occurenceVoxelKey.voxelVariantId == voxelVariantId,
        "invalid terrain voxel variant"
      );

      // Create an ECS voxel from this coord's terrain voxel
      voxelToMine = getUniqueEntity();
      // in terrain gen, we know its our system namespace and we validated it above using the Occurrence table
      VoxelType.set(voxelToMine, namespace, voxelTypeId, voxelVariantNamespace, voxelVariantId);
    } else {
      // Else, mine the non-air entity voxel at this position
      require(entitiesAtPosition.length == 1, "there should only be one entity at this position");
      voxelToMine = entitiesAtPosition[0];
      VoxelTypeData memory voxelTypeData = VoxelType.get(entitiesAtPosition[0]);
      require(voxelToMine != 0, "We found no voxels at that position");
      require(voxelTypeData.voxelTypeNamespace != voxelTypeNamespace
              && voxelTypeData.voxelTypeId != voxelTypeId
              && voxelTypeData.voxelVariantNamespace != voxelVariantNamespace
              && voxelTypeData.voxelVariantId != voxelVariantId,
              "The voxel at this position is not the same as the voxel you are trying to mine");
      Position.deleteRecord(voxelToMine);

      // TODO: should reset component values
    }

    // Place an air voxel at this position
    airEntity = getUniqueEntity();
    {
      // get Air selector from VoxelTypeRegistry
      bytes4 airSelector = VoxelTypeRegistry.get(namespace, AirID).voxelVariantSelector;
      // call airSelector
      (bool airSuccess, bytes memory airVoxelVariant) = staticcallFunctionSelector(
        airSelector,
        abi.encode(airEntity)
      );
      require(airSuccess, "failed to get air voxel type");
      VoxelVariantsKey memory airVariantData = abi.decode(airVoxelVariant, (VoxelVariantsKey));
      VoxelType.set(airEntity, namespace, AirID, airVariantData.namespace, airVariantData.voxelVariantId);
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