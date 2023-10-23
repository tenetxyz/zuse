// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant SimpleGlassOutset1152BlackVoxelID = bytes32(keccak256("simple_glass_outset_1152_black"));
bytes32 constant SimpleGlassOutset1152BlackVoxelVariantID = bytes32(keccak256("simple_glass_outset_1152_black"));

contract SimpleGlassOutset1152BlackVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory simpleGlassOutset1152BlackVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, SimpleGlassOutset1152BlackVoxelVariantID, simpleGlassOutset1152BlackVariant);

    bytes32[] memory simpleGlassOutset1152BlackChildVoxelTypes = new bytes32[](1);
    simpleGlassOutset1152BlackChildVoxelTypes[0] = SimpleGlassOutset1152BlackVoxelID;
    bytes32 baseVoxelTypeId = SimpleGlassOutset1152BlackVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Simple Glass Outset1152 Black",
      SimpleGlassOutset1152BlackVoxelID,
      baseVoxelTypeId,
      simpleGlassOutset1152BlackChildVoxelTypes,
      simpleGlassOutset1152BlackChildVoxelTypes,
      SimpleGlassOutset1152BlackVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C33554433D1152E9_enterWorld.selector,
        IWorld(world).pretty_C33554433D1152E9_exitWorld.selector,
        IWorld(world).pretty_C33554433D1152E9_variantSelector.selector,
        IWorld(world).pretty_C33554433D1152E9_activate.selector,
        IWorld(world).pretty_C33554433D1152E9_eventHandler.selector,
        IWorld(world).pretty_C33554433D1152E9_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, SimpleGlassOutset1152BlackVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return SimpleGlassOutset1152BlackVoxelVariantID;
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
