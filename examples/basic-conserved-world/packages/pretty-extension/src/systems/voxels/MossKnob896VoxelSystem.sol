// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant MossKnob896VoxelID = bytes32(keccak256("moss_knob_896"));
bytes32 constant MossKnob896VoxelVariantID = bytes32(keccak256("moss_knob_896"));

contract MossKnob896VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory mossKnob896Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, MossKnob896VoxelVariantID, mossKnob896Variant);

    bytes32[] memory mossKnob896ChildVoxelTypes = new bytes32[](1);
    mossKnob896ChildVoxelTypes[0] = MossKnob896VoxelID;
    bytes32 baseVoxelTypeId = MossKnob896VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Moss Knob896",
      MossKnob896VoxelID,
      baseVoxelTypeId,
      mossKnob896ChildVoxelTypes,
      mossKnob896ChildVoxelTypes,
      MossKnob896VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C40D896_enterWorld.selector,
        IWorld(world).pretty_C40D896_exitWorld.selector,
        IWorld(world).pretty_C40D896_variantSelector.selector,
        IWorld(world).pretty_C40D896_activate.selector,
        IWorld(world).pretty_C40D896_eventHandler.selector,
        IWorld(world).pretty_C40D896_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, MossKnob896VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return MossKnob896VoxelVariantID;
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
