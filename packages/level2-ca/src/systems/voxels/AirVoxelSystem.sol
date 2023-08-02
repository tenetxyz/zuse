// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { AirVoxelID, AirVoxelVariantID } from "@tenet-base-ca/src/Constants.sol";

contract AirVoxelSystem is System {
  function registerVoxelAir() public {
    address world = _world();
    bytes32[] memory airChildVoxelTypes = new bytes32[](8);
    for (uint i = 0; i < 8; i++) {
      airChildVoxelTypes[i] = AirVoxelID;
    }
    bytes32 baseVoxelTypeId = Level2AirVoxelID;
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Level 2 Air",
      Level2AirVoxelID,
      baseVoxelTypeId,
      airChildVoxelTypes,
      airChildVoxelTypes,
      AirVoxelVariantID
    );

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      Level2AirVoxelID,
      IWorld(world).enterWorldAir.selector,
      IWorld(world).exitWorldAir.selector,
      IWorld(world).variantSelectorAir.selector,
      IWorld(world).activateSelectorAir.selector,
      IWorld(world).eventHandlerAir.selector
    );
  }

  function enterWorldAir(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function exitWorldAir(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function variantSelectorAir(
    address callerAddress,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view returns (bytes32) {
    return AirVoxelVariantID;
  }

  function activateSelectorAir(address callerAddress, bytes32 entity) public view returns (string memory) {}

  function eventHandlerAir(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory) {}
}
