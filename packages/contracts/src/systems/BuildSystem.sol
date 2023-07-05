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
  // function checkIfShouldFall(VoxelVariantsData memory voxelTop, VoxelVariantsData voxelBottom) public returns (bool) {
  //   // check if the mass of the voxel is greater than the mass of the voxel below it
  //   return voxelTop.mass > voxelBottom.mass;
  // }

  function runGravityLogic(bytes32 entity) public {
    // entity was just placed
    // we need to go through it and all voxels below it and apply gravity
    // PositionData memory coord = Position.get(entity);
    // // get the entity below this
    // bytes32[] memory neighbourEntitiesAtPosition = getEntitiesAtCoord(VoxelCoord(coord.x, coord.y - 1, coord.z));
    // // if the entity doesn't exist, then this means its part of the terrain, so need to get the terrain entity
    // bytes32 compareEntity;
    // if (neighbourEntitiesAtPosition.length == 0) {} else {
    //   compareEntity = neighbourEntitiesAtPosition[0];
    // }
    // bool shouldFall = checkIfShouldFall(entity, compareEntity);
    // if (shouldFall) {
    //   // break the block and move it down
    //   // this should really be a call to mine, then a recursive call to build
    // }
  }

  function build(bytes32 entity, VoxelCoord memory coord) public returns (bytes32) {
    // Require voxel to be owned by caller
    require(OwnedBy.get(entity) == addressToEntityKey(_msgSender()), "voxel is not owned by player");

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

    VoxelTypeData memory entityVoxelData = VoxelType.get(entity);
    VoxelType.set(newEntity, entityVoxelData);
    // Note: Need to run this because we are in creative mode and this is a new entity
    enterVoxelIntoWorld(_world(), newEntity);
    updateVoxelVariant(_world(), newEntity);

    increaseVoxelTypeSpawnCount(entityVoxelData.voxelTypeNamespace, entityVoxelData.voxelTypeId);
    // Run gravity logic
    runGravityLogic(newEntity);

    // Run voxel interaction logic
    IWorld(_world()).tenet_VoxInteractSys_runInteractionSystems(newEntity);

    return newEntity;
  }
}
