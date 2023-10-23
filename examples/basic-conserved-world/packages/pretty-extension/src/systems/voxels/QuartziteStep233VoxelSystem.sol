// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant QuartziteStep233VoxelID = bytes32(keccak256("quartzite_step_233"));
bytes32 constant QuartziteStep233VoxelVariantID = bytes32(keccak256("quartzite_step_233"));

contract QuartziteStep233VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory quartziteStep233Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, QuartziteStep233VoxelVariantID, quartziteStep233Variant);

    bytes32[] memory quartziteStep233ChildVoxelTypes = new bytes32[](1);
    quartziteStep233ChildVoxelTypes[0] = QuartziteStep233VoxelID;
    bytes32 baseVoxelTypeId = QuartziteStep233VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Quartzite Step233",
      QuartziteStep233VoxelID,
      baseVoxelTypeId,
      quartziteStep233ChildVoxelTypes,
      quartziteStep233ChildVoxelTypes,
      QuartziteStep233VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C7D233_enterWorld.selector,
        IWorld(world).pretty_C7D233_exitWorld.selector,
        IWorld(world).pretty_C7D233_variantSelector.selector,
        IWorld(world).pretty_C7D233_activate.selector,
        IWorld(world).pretty_C7D233_eventHandler.selector,
        IWorld(world).pretty_C7D233_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, QuartziteStep233VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return QuartziteStep233VoxelVariantID;
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
