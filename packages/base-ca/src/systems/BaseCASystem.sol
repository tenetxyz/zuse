// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { VoxelType, Position, PositionData } from "@base-ca/src/codegen/Tables.sol";
import { VoxelCoord } from "@tenet-registry/src/Types.sol";

contract BaseCASystem is System {
  function enterWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 entity) public {
    address callerAddress = msg.sender;

    Position.set(callerAddress, entity, PositionData({ x: coord.x, y: coord.y, z: coord.z }));
    // VoxelVariantsKey memory voxelVariantData = updateVoxelVariant(entity);
    bytes32 voxelVariantId;
    VoxelType.set(callerAddress, entity, voxelTypeId, voxelVariantId);
  }

  // function updateVoxelVariant(bytes32 entity) public returns () {}

  // function exitWorld(bytes32 entity) public {
  //   address callerAddress = msg.sender;
  //   // call exitWorld() in other contracts
  //   BasePosition.deleteRecord(callerAddress, entity);
  //   BaseType.deleteRecord(callerAddress, entity);
  // }

  // // called by world
  // function runInteraction(
  //   bytes32 interactEntity,
  //   bytes32[] memory neighbourEntityIds,
  //   bytes32[] memory childEntityIds,
  //   bytes32[] memory parentEntityIds
  // ) public {
  //   // loop over all neighbours and run interaction logic
  //   // the interaction's used will can be in different namespaces
  //   // just hard coded, or registered
  //   runInteractionSystems(entity);

  //   // can change type at position
  //   // define valid movements
  // }

  // function moveEntities(bytes32[] entity) public {
  //   // use callerNamespace
  //   // define valid movements
  // }
}
