// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { VoxelTypeData, Position, PositionData, BasePosition } from "@tenet-contracts/src/codegen/Tables.sol";
import { VoxelVariantsKey } from "@tenet-contracts/src/Types.sol";
import { BlockDirection } from "@tenet-contracts/src/Types.sol";

contract BaseCASystem is System {
  function enterWorld(VoxelTypeData memory voxelType, bytes32 entity, bytes32 parentEntity) public {
    address callerAddress = msg.sender;

    // entity has been placed in the world
    PositionData memory baseCoord = Position.get(entity);
    // we just store the same position as in the world
    BasePosition.set(callerAddress, entity, baseCoord);
    VoxelVariantsKey memory voxelVariantData = updateVoxelVariant(entity);
    BaseType.set(callerAddress, entity, voxelVariantData);

    // call enterWorld() in other contracts
  }

  function exitWorld(bytes32 entity) public {
    address callerAddress = msg.sender;
    // call exitWorld() in other contracts
    BasePosition.deleteRecord(callerAddress, entity);
    BaseType.deleteRecord(callerAddress, entity);
  }

  // called by world
  function runInteraction(bytes32 interactEntity, bytes32[] memory neighbourEntityIds) public {
    // loop over all neighbours and run interaction logic
    // the interaction's used will can be in different namespaces
    // just hard coded, or registered
    runInteractionSystems(entity);
  }
}
