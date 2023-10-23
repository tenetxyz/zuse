// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant SimpleGlassSlab128PurpleVoxelID = bytes32(keccak256("simple_glass_slab_128_purple"));
bytes32 constant SimpleGlassSlab128PurpleVoxelVariantID = bytes32(keccak256("simple_glass_slab_128_purple"));

contract SimpleGlassSlab128PurpleVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory simpleGlassSlab128PurpleVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, SimpleGlassSlab128PurpleVoxelVariantID, simpleGlassSlab128PurpleVariant);

    bytes32[] memory simpleGlassSlab128PurpleChildVoxelTypes = new bytes32[](1);
    simpleGlassSlab128PurpleChildVoxelTypes[0] = SimpleGlassSlab128PurpleVoxelID;
    bytes32 baseVoxelTypeId = SimpleGlassSlab128PurpleVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Simple Glass Slab128 Purple",
      SimpleGlassSlab128PurpleVoxelID,
      baseVoxelTypeId,
      simpleGlassSlab128PurpleChildVoxelTypes,
      simpleGlassSlab128PurpleChildVoxelTypes,
      SimpleGlassSlab128PurpleVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C33554433D128E6_enterWorld.selector,
        IWorld(world).pretty_C33554433D128E6_exitWorld.selector,
        IWorld(world).pretty_C33554433D128E6_variantSelector.selector,
        IWorld(world).pretty_C33554433D128E6_activate.selector,
        IWorld(world).pretty_C33554433D128E6_eventHandler.selector,
        IWorld(world).pretty_C33554433D128E6_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, SimpleGlassSlab128PurpleVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return SimpleGlassSlab128PurpleVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bool, bytes memory) {}

  function neighbourEventHandler(
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public override returns (bool, bytes memory) {}
}
