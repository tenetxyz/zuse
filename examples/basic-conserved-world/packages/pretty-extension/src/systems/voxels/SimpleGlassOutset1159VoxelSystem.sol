// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant SimpleGlassOutset1159VoxelID = bytes32(keccak256("simple_glass_outset_1159"));
bytes32 constant SimpleGlassOutset1159VoxelVariantID = bytes32(keccak256("simple_glass_outset_1159"));

contract SimpleGlassOutset1159VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory simpleGlassOutset1159Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, SimpleGlassOutset1159VoxelVariantID, simpleGlassOutset1159Variant);

    bytes32[] memory simpleGlassOutset1159ChildVoxelTypes = new bytes32[](1);
    simpleGlassOutset1159ChildVoxelTypes[0] = SimpleGlassOutset1159VoxelID;
    bytes32 baseVoxelTypeId = SimpleGlassOutset1159VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Simple Glass Outset1159",
      SimpleGlassOutset1159VoxelID,
      baseVoxelTypeId,
      simpleGlassOutset1159ChildVoxelTypes,
      simpleGlassOutset1159ChildVoxelTypes,
      SimpleGlassOutset1159VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C33554433D1159_enterWorld.selector,
        IWorld(world).pretty_C33554433D1159_exitWorld.selector,
        IWorld(world).pretty_C33554433D1159_variantSelector.selector,
        IWorld(world).pretty_C33554433D1159_activate.selector,
        IWorld(world).pretty_C33554433D1159_eventHandler.selector,
        IWorld(world).pretty_C33554433D1159_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, SimpleGlassOutset1159VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return SimpleGlassOutset1159VoxelVariantID;
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
