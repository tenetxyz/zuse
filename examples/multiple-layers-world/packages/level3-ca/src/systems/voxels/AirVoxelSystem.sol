// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level3-ca/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, Level3AirVoxelID } from "@tenet-level3-ca/src/Constants.sol";
import { Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";
import { AirVoxelVariantID } from "@tenet-level1-ca/src/Constants.sol";

contract AirVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    bytes32[] memory airChildVoxelTypes = new bytes32[](8);
    for (uint i = 0; i < 8; i++) {
      airChildVoxelTypes[i] = Level2AirVoxelID;
    }
    bytes32 baseVoxelTypeId = Level3AirVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Level 3 Air",
      Level3AirVoxelID,
      baseVoxelTypeId,
      airChildVoxelTypes,
      airChildVoxelTypes,
      AirVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).ca_AirVoxelSystem_enterWorld.selector,
        IWorld(world).ca_AirVoxelSystem_exitWorld.selector,
        IWorld(world).ca_AirVoxelSystem_variantSelector.selector,
        IWorld(world).ca_AirVoxelSystem_activate.selector,
        IWorld(world).ca_AirVoxelSystem_eventHandler.selector
      ),
      abi.encode(componentDefs)
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
  ) public override returns (bytes32, bytes32[] memory, bytes[] memory) {}
}
