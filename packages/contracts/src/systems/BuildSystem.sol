// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "@tenet-registry/src/Types.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { OwnedBy, Position, PositionTableId, VoxelType, VoxelTypeData } from "@tenet-contracts/src/codegen/Tables.sol";
import { addressToEntityKey, enterVoxelIntoWorld, updateVoxelVariant, increaseVoxelTypeSpawnCount } from "../Utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";

IStore constant REGISTRY_WORLD_STORE = IStore(0x5FbDB2315678afecb367f032d93F642f64180aa3);
address constant BASE_CA_ADDRESS = 0x5FbDB2315678afecb367f032d93F642f64180aa3;

contract BuildSystem is System {
  // function build(bytes32 entity, VoxelCoord memory coord) public returns (bytes32) {
  //   // Require voxel to be owned by caller
  //   require(OwnedBy.get(entity) == addressToEntityKey(_msgSender()), "voxel is not owned by player");

  //   VoxelTypeData memory voxelType = VoxelType.get(entity);
  //   return buildVoxelType(voxelType, coord);
  // }

  function isCAAllowed(address caAddress) public view returns (bool) {
    return caAddress == BASE_CA_ADDRESS;
  }

  // TODO: when we have a survival mode, prevent ppl from alling this function directly (since they don't need to own the voxel to call it)
  function buildVoxelType(bytes32 voxelTypeId, VoxelCoord memory coord) public returns (bytes32) {
    address caAddress = VoxelTypeRegistry.get(REGISTRY_WORLD_STORE, voxelType);
    require(isCAAllowed(caAddress), "Invalid CA address");

    // // Require no other ECS voxels at this position except Air
    // bytes32[] memory entitiesAtPosition = getKeysWithValue(PositionTableId, Position.encode(coord.x, coord.y, coord.z));
    // require(entitiesAtPosition.length <= 1, "This position is already occupied by another voxel");
    // if (entitiesAtPosition.length == 1) {
    //   require(
    //     VoxelType.get(entitiesAtPosition[0]).voxelTypeId == AirID,
    //     "This position is already occupied by another voxel"
    //   );
    //   VoxelType.deleteRecord(entitiesAtPosition[0]);
    //   Position.deleteRecord(entitiesAtPosition[0]);
    // }

    // // TODO: check claim in chunk
    // //    OwnedBy.deleteRecord(voxel);
    // bytes32 newEntity = getUniqueEntity();
    // Position.set(newEntity, coord.x, coord.y, coord.z);

    // VoxelType.set(newEntity, voxelType);
    // // Note: Need to run this because we are in creative mode and this is a new entity
    // enterVoxelIntoWorld(_world(), newEntity);
    // updateVoxelVariant(_world(), newEntity);

    // increaseVoxelTypeSpawnCount(voxelType.voxelTypeNamespace, voxelType.voxelTypeId);

    // // Run voxel interaction logic
    // IWorld(_world()).tenet_VoxInteractSys_runInteractionSystems(newEntity);

    return newEntity;
  }
}
