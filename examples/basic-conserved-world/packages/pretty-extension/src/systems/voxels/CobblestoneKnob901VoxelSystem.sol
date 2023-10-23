// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CobblestoneKnob901VoxelID = bytes32(keccak256("cobblestone_knob_901"));
bytes32 constant CobblestoneKnob901VoxelVariantID = bytes32(keccak256("cobblestone_knob_901"));

contract CobblestoneKnob901VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cobblestoneKnob901Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CobblestoneKnob901VoxelVariantID, cobblestoneKnob901Variant);

    bytes32[] memory cobblestoneKnob901ChildVoxelTypes = new bytes32[](1);
    cobblestoneKnob901ChildVoxelTypes[0] = CobblestoneKnob901VoxelID;
    bytes32 baseVoxelTypeId = CobblestoneKnob901VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cobblestone Knob901",
      CobblestoneKnob901VoxelID,
      baseVoxelTypeId,
      cobblestoneKnob901ChildVoxelTypes,
      cobblestoneKnob901ChildVoxelTypes,
      CobblestoneKnob901VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C5D901_enterWorld.selector,
        IWorld(world).pretty_C5D901_exitWorld.selector,
        IWorld(world).pretty_C5D901_variantSelector.selector,
        IWorld(world).pretty_C5D901_activate.selector,
        IWorld(world).pretty_C5D901_eventHandler.selector,
        IWorld(world).pretty_C5D901_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CobblestoneKnob901VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CobblestoneKnob901VoxelVariantID;
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
