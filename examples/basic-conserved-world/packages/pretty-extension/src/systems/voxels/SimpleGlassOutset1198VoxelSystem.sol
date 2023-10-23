// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant SimpleGlassOutset1198VoxelID = bytes32(keccak256("simple_glass_outset_1198"));
bytes32 constant SimpleGlassOutset1198VoxelVariantID = bytes32(keccak256("simple_glass_outset_1198"));

contract SimpleGlassOutset1198VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory simpleGlassOutset1198Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, SimpleGlassOutset1198VoxelVariantID, simpleGlassOutset1198Variant);

    bytes32[] memory simpleGlassOutset1198ChildVoxelTypes = new bytes32[](1);
    simpleGlassOutset1198ChildVoxelTypes[0] = SimpleGlassOutset1198VoxelID;
    bytes32 baseVoxelTypeId = SimpleGlassOutset1198VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Simple Glass Outset1198",
      SimpleGlassOutset1198VoxelID,
      baseVoxelTypeId,
      simpleGlassOutset1198ChildVoxelTypes,
      simpleGlassOutset1198ChildVoxelTypes,
      SimpleGlassOutset1198VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C33554433D1198_enterWorld.selector,
        IWorld(world).pretty_C33554433D1198_exitWorld.selector,
        IWorld(world).pretty_C33554433D1198_variantSelector.selector,
        IWorld(world).pretty_C33554433D1198_activate.selector,
        IWorld(world).pretty_C33554433D1198_eventHandler.selector,
        IWorld(world).pretty_C33554433D1198_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, SimpleGlassOutset1198VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return SimpleGlassOutset1198VoxelVariantID;
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
