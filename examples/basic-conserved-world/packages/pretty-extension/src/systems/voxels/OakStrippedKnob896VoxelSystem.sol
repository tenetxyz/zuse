// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakStrippedKnob896VoxelID = bytes32(keccak256("oak_stripped_knob_896"));
bytes32 constant OakStrippedKnob896VoxelVariantID = bytes32(keccak256("oak_stripped_knob_896"));

contract OakStrippedKnob896VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakStrippedKnob896Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakStrippedKnob896VoxelVariantID, oakStrippedKnob896Variant);

    bytes32[] memory oakStrippedKnob896ChildVoxelTypes = new bytes32[](1);
    oakStrippedKnob896ChildVoxelTypes[0] = OakStrippedKnob896VoxelID;
    bytes32 baseVoxelTypeId = OakStrippedKnob896VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Stripped Knob896",
      OakStrippedKnob896VoxelID,
      baseVoxelTypeId,
      oakStrippedKnob896ChildVoxelTypes,
      oakStrippedKnob896ChildVoxelTypes,
      OakStrippedKnob896VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C73D896_enterWorld.selector,
        IWorld(world).pretty_C73D896_exitWorld.selector,
        IWorld(world).pretty_C73D896_variantSelector.selector,
        IWorld(world).pretty_C73D896_activate.selector,
        IWorld(world).pretty_C73D896_eventHandler.selector,
        IWorld(world).pretty_C73D896_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakStrippedKnob896VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakStrippedKnob896VoxelVariantID;
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
