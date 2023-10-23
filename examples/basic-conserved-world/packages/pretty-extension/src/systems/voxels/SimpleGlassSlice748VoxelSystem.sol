// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant SimpleGlassSlice748VoxelID = bytes32(keccak256("simple_glass_slice_748"));
bytes32 constant SimpleGlassSlice748VoxelVariantID = bytes32(keccak256("simple_glass_slice_748"));

contract SimpleGlassSlice748VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory simpleGlassSlice748Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, SimpleGlassSlice748VoxelVariantID, simpleGlassSlice748Variant);

    bytes32[] memory simpleGlassSlice748ChildVoxelTypes = new bytes32[](1);
    simpleGlassSlice748ChildVoxelTypes[0] = SimpleGlassSlice748VoxelID;
    bytes32 baseVoxelTypeId = SimpleGlassSlice748VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Simple Glass Slice748",
      SimpleGlassSlice748VoxelID,
      baseVoxelTypeId,
      simpleGlassSlice748ChildVoxelTypes,
      simpleGlassSlice748ChildVoxelTypes,
      SimpleGlassSlice748VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C33554433D748_enterWorld.selector,
        IWorld(world).pretty_C33554433D748_exitWorld.selector,
        IWorld(world).pretty_C33554433D748_variantSelector.selector,
        IWorld(world).pretty_C33554433D748_activate.selector,
        IWorld(world).pretty_C33554433D748_eventHandler.selector,
        IWorld(world).pretty_C33554433D748_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, SimpleGlassSlice748VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return SimpleGlassSlice748VoxelVariantID;
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
