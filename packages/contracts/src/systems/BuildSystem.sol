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
  function build(bytes32 entity, VoxelCoord memory coord) public returns (bytes32) {
    // Require voxel to be owned by caller
    require(OwnedBy.get(entity) == addressToEntityKey(_msgSender()), "voxel is not owned by player");

    VoxelTypeData memory voxelType = VoxelType.get(entity);
    return buildVoxelType(voxelType, coord);
  }

  // TODO: when we have a survival mode, prevent ppl from alling this funciton directly (since they don't need to own the voxel to call it)
  function buildVoxelType(VoxelTypeData memory voxelType, VoxelCoord memory coord) public returns (bytes32) {
    // Require no other ECS voxels at this position except Air
    bytes32[] memory entitiesAtPosition = getKeysWithValue(PositionTableId, Position.encode(coord.x, coord.y, coord.z));
    require(entitiesAtPosition.length <= 1, "This position is already occupied by another voxel");
    if (entitiesAtPosition.length == 1) {
      require(
        VoxelType.get(entitiesAtPosition[0]).voxelTypeId == AirID,
        "This position is already occupied by another voxel"
      );
      VoxelType.deleteRecord(entitiesAtPosition[0]);
      Position.deleteRecord(entitiesAtPosition[0]);
    }

    // TODO: check claim in chunk
    //    OwnedBy.deleteRecord(voxel);
    bytes32 newEntity = getUniqueEntity();
    Position.set(newEntity, coord.x, coord.y, coord.z);

    VoxelType.set(newEntity, voxelType);
    // Note: Need to run this because we are in creative mode and this is a new entity
    enterVoxelIntoWorld(_world(), newEntity);
    updateVoxelVariant(_world(), newEntity);

    increaseVoxelTypeSpawnCount(voxelType.voxelTypeNamespace, voxelType.voxelTypeId);

    // Run voxel interaction logic
    IWorld(_world()).tenet_VoxInteractSys_runInteractionSystems(newEntity);

    return newEntity;
  }
}
