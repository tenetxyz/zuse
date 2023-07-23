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
import { safeCall, isCAAllowed } from "@tenet-contracts/src/Utils.sol";
import { CAVoxelType, CAVoxelTypeData, CAVoxelTypeDefs } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { REGISTRY_WORLD_STORE, BASE_CA_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { add } from "./VoxelInteractionSystem.sol";

contract BuildSystem is System {
  function build(bytes32 entity, VoxelCoord memory coord) public returns (bytes32) {
    // Require voxel to be owned by caller
    require(OwnedBy.get(entity) == addressToEntityKey(_msgSender()), "voxel is not owned by player");

    VoxelTypeData memory voxelType = VoxelType.get(0, entity);
    return buildVoxelType(voxelType.voxelTypeId, coord);
  }

  // TODO: when we have a survival mode, prevent ppl from alling this function directly (since they don't need to own the voxel to call it)
  function buildVoxelType(bytes32 voxelTypeId, VoxelCoord memory coord) public returns (bytes32) {
    address caAddress = VoxelTypeRegistry.get(REGISTRY_WORLD_STORE, voxelTypeId).caAddress;
    require(isCAAllowed(caAddress), "Invalid CA address");

    address workingCaAddress = caAddress;
    uint256 scaleId = 0; // TODO: make this a parameter
    if (workingCaAddress != BASE_CA_ADDRESS) {
      scaleId += 1;

      // Read the ChildTypes in this CA address
      bytes32[] childVoxelTypeIds = CAVoxelTypeDefs.get(IStore(caAddress), voxelTypeId);
      require(childVoxelTypeIds.length == 8, "Invalid length of child voxel type ids");

      // TODO: move this to a library
      VoxelCoord[] memory eightBlockVoxelCoords = new VoxelCoord[](8);
      eightBlockVoxelCoords[0] = VoxelCoord({ x: 0, y: 0, z: 0 });
      eightBlockVoxelCoords[1] = VoxelCoord({ x: 1, y: 0, z: 0 });
      eightBlockVoxelCoords[2] = VoxelCoord({ x: 0, y: 1, z: 0 });
      eightBlockVoxelCoords[3] = VoxelCoord({ x: 1, y: 1, z: 0 });
      eightBlockVoxelCoords[4] = VoxelCoord({ x: 0, y: 0, z: 1 });
      eightBlockVoxelCoords[5] = VoxelCoord({ x: 1, y: 0, z: 1 });
      eightBlockVoxelCoords[6] = VoxelCoord({ x: 0, y: 1, z: 1 });
      eightBlockVoxelCoords[7] = VoxelCoord({ x: 1, y: 1, z: 1 });

      for (uint8 i = 0; i < 8; i++) {
        VoxelCoord useCoord = buildVoxelType(childVoxelTypeIds[i], add(coord, eightBlockVoxelCoords[i]));
        build(childVoxelTypeIds[i], useCoord);
      }

      // And keep looping until we get to the base CA address
      // build(childVoxelType, coord)
    }
    // After we've built all the child types, we can build the parent type
    bytes32 newEntity = getUniqueEntity();

    // Enter World
    IWorld(_world()).tenet_VoxInteractSys_enterCA(caAddress, voxelTypeId, coord, newEntity);

    // Set Position
    Position.set(scaleId, newEntity, coord.x, coord.y, coord.z);
    // Set initial voxel type
    // TODO: Need to use _world() instead of address(this) here
    CAVoxelTypeData memory entityCAVoxelType = IWorld(_world()).tenet_VoxInteractSys_readCAVoxelTypes(
      caAddress,
      newEntity
    );
    VoxelType.set(scaleId, newEntity, entityCAVoxelType.voxelTypeId, entityCAVoxelType.voxelVariantId);

    IWorld(_world()).tenet_VoxInteractSys_runCA(caAddress, scaleId, newEntity);

    return newEntity;
  }
}
