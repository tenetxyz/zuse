// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { BodyVariantsRegistryData } from "@tenet-registry/src/codegen/tables/BodyVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerBodyVariant, registerBodyType, bodySelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { AirVoxelID, AirVoxelVariantID } from "@tenet-base-ca/src/Constants.sol";

contract AirVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();
    bytes32[] memory airChildBodyTypes = new bytes32[](8);
    for (uint i = 0; i < 8; i++) {
      airChildBodyTypes[i] = AirVoxelID;
    }
    bytes32 baseBodyTypeId = Level2AirVoxelID;
    registerBodyType(
      REGISTRY_ADDRESS,
      "Level 2 Air",
      Level2AirVoxelID,
      baseBodyTypeId,
      airChildBodyTypes,
      airChildBodyTypes,
      AirVoxelVariantID,
      bodySelectorsForVoxel(
        IWorld(world).ca_AirVoxelSystem_enterWorld.selector,
        IWorld(world).ca_AirVoxelSystem_exitWorld.selector,
        IWorld(world).ca_AirVoxelSystem_variantSelector.selector,
        IWorld(world).ca_AirVoxelSystem_activate.selector,
        IWorld(world).ca_AirVoxelSystem_eventHandler.selector
      )
    );
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return AirVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32, bytes32[] memory) {}
}
