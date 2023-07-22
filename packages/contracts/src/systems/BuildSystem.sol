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
import { safeCall } from "@tenet-contracts/src/Utils.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";

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

    address workingCaAddress = caAddress;
    uint256 scaleId = 0; // TODO: make this a parameter
    while (workingCaAddress != BASE_CA_ADDRESS) {
      depth += 1;
      // Read the ChildTypes in this CA address
      // Figure out their CA address
      // And keep looping until we get to the base CA address
      // build(childVoxelType, coord)
    }
    // After we've built all the child types, we can build the parent type
    bytes32 newEntity = getUniqueEntity();

    // Enter World
    safeCall(
      caAddress,
      abi.encodeWithSignature("enterWorld(bytes32,(int32,int32,int32),bytes32)", voxelType, coord, newEntity),
      string(abi.encodePacked("enterWorld ", voxelType, " ", coord, " ", newEntity))
    );

    // Set Position
    Position.set(scaleId, newEntity, coord.x, coord.y, coord.z);

    // Run interaction logic
    bytes32[] memory neighbourEntityIds = IWorld(_world()).tenet_VoxInteractSys_calculateNeighbourEntities(newEntity);
    bytes32[] memory childEntityIds;
    bytes32[] memory parentEntityIds;
    bytes memory returnData = safeCall(
      caAddress,
      abi.encodeWithSignature(
        "runInteraction(bytes32,bytes32[],bytes32[],bytes32[])",
        newEntity,
        neighbourEntityIds,
        childEntityIds,
        parentEntityIds
      ),
      string(
        abi.encodePacked(
          "runInteraction ",
          newEntity,
          " ",
          neighbourEntityIds,
          " ",
          childEntityIds,
          " ",
          parentEntityIds
        )
      )
    );
    bytes32[] memory changedEntities = abi.decode(returnData, (bytes32[]));

    // Update VoxelType and Position at this level to match the CA
    for (uint256 i = 0; i < changedEntities.length; i++) {
      bytes32 changedEntity = changedEntities[i];
      CAVoxelTypeData changedEntityVoxelType = CAVoxelType.get(IStore(caAddress), _world(), changedEntity);
      // Update VoxelType
      VoxelType.set(
        scaleId,
        changedEntities[i],
        changedEntityVoxelType.voxelTypeId,
        changedEntityVoxelType.voxelVariantId
      );
      // TODO: Do we need this?
      // Position should not change of the entity
      // Position.set(scaleId, changedEntities[i], coord.x, coord.y, coord.z);
    }

    return newEntity;
  }
}
