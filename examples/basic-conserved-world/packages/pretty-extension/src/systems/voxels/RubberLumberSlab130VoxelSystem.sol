// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberLumberSlab130VoxelID = bytes32(keccak256("rubber_lumber_slab_130"));
bytes32 constant RubberLumberSlab130VoxelVariantID = bytes32(keccak256("rubber_lumber_slab_130"));

contract RubberLumberSlab130VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberLumberSlab130Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberLumberSlab130VoxelVariantID, rubberLumberSlab130Variant);

    bytes32[] memory rubberLumberSlab130ChildVoxelTypes = new bytes32[](1);
    rubberLumberSlab130ChildVoxelTypes[0] = RubberLumberSlab130VoxelID;
    bytes32 baseVoxelTypeId = RubberLumberSlab130VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Lumber Slab130",
      RubberLumberSlab130VoxelID,
      baseVoxelTypeId,
      rubberLumberSlab130ChildVoxelTypes,
      rubberLumberSlab130ChildVoxelTypes,
      RubberLumberSlab130VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C34D130_enterWorld.selector,
        IWorld(world).pretty_C34D130_exitWorld.selector,
        IWorld(world).pretty_C34D130_variantSelector.selector,
        IWorld(world).pretty_C34D130_activate.selector,
        IWorld(world).pretty_C34D130_eventHandler.selector,
        IWorld(world).pretty_C34D130_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberLumberSlab130VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberLumberSlab130VoxelVariantID;
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
