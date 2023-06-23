// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../types.sol";
import { OwnedBy, Position, PositionTableId, VoxelType } from "../codegen/Tables.sol";
import { AirID } from "../prototypes/Voxels.sol";
import { addressToEntityKey } from "../utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { IWorld } from "../codegen/world/IWorld.sol";

contract BuildSystem is System {

  function build(bytes32 voxel, VoxelCoord memory coord) public returns (bytes32) {

    // Require voxel to be owned by caller
    require(OwnedBy.get(voxel) == addressToEntityKey(_msgSender()), "voxel is not owned by player");

    // Require no other ECS voxels at this position except Air
    bytes32[] memory entitiesAtPosition = getKeysWithValue(PositionTableId, Position.encode(coord.x, coord.y, coord.z));
    require(entitiesAtPosition.length <= 1, "This position is already occupied by another voxel");
    if (entitiesAtPosition.length == 1) {
      require(VoxelType.get(entitiesAtPosition[0]) == AirID, "This position is already occupied by another voxel");
      VoxelType.deleteRecord(entitiesAtPosition[0]);
      Position.deleteRecord(entitiesAtPosition[0]);
    }

    // TODO: check claim in chunk
    //    OwnedBy.deleteRecord(voxel);
    bytes32 newEntity = getUniqueEntity();
    VoxelType.set(newEntity, VoxelType.get(voxel));
    Position.set(newEntity, coord.x, coord.y, coord.z);

    // Run voxel interaction logic
    IWorld(_world()).tenet_VoxelInteraction_runInteractionSystems(newEntity);

    return newEntity;
  }

}