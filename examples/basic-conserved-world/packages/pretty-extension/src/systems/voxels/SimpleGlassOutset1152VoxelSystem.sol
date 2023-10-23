// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant SimpleGlassOutset1152VoxelID = bytes32(keccak256("simple_glass_outset_1152"));
bytes32 constant SimpleGlassOutset1152VoxelVariantID = bytes32(keccak256("simple_glass_outset_1152"));

contract SimpleGlassOutset1152VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory simpleGlassOutset1152Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, SimpleGlassOutset1152VoxelVariantID, simpleGlassOutset1152Variant);

    bytes32[] memory simpleGlassOutset1152ChildVoxelTypes = new bytes32[](1);
    simpleGlassOutset1152ChildVoxelTypes[0] = SimpleGlassOutset1152VoxelID;
    bytes32 baseVoxelTypeId = SimpleGlassOutset1152VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Simple Glass Outset1152",
      SimpleGlassOutset1152VoxelID,
      baseVoxelTypeId,
      simpleGlassOutset1152ChildVoxelTypes,
      simpleGlassOutset1152ChildVoxelTypes,
      SimpleGlassOutset1152VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C33554433D1152_enterWorld.selector,
        IWorld(world).pretty_C33554433D1152_exitWorld.selector,
        IWorld(world).pretty_C33554433D1152_variantSelector.selector,
        IWorld(world).pretty_C33554433D1152_activate.selector,
        IWorld(world).pretty_C33554433D1152_eventHandler.selector,
        IWorld(world).pretty_C33554433D1152_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, SimpleGlassOutset1152VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return SimpleGlassOutset1152VoxelVariantID;
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
