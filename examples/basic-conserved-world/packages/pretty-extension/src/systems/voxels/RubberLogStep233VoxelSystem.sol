// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberLogStep233VoxelID = bytes32(keccak256("rubber_log_step_233"));
bytes32 constant RubberLogStep233VoxelVariantID = bytes32(keccak256("rubber_log_step_233"));

contract RubberLogStep233VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberLogStep233Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberLogStep233VoxelVariantID, rubberLogStep233Variant);

    bytes32[] memory rubberLogStep233ChildVoxelTypes = new bytes32[](1);
    rubberLogStep233ChildVoxelTypes[0] = RubberLogStep233VoxelID;
    bytes32 baseVoxelTypeId = RubberLogStep233VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Log Step233",
      RubberLogStep233VoxelID,
      baseVoxelTypeId,
      rubberLogStep233ChildVoxelTypes,
      rubberLogStep233ChildVoxelTypes,
      RubberLogStep233VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C14D233_enterWorld.selector,
        IWorld(world).pretty_C14D233_exitWorld.selector,
        IWorld(world).pretty_C14D233_variantSelector.selector,
        IWorld(world).pretty_C14D233_activate.selector,
        IWorld(world).pretty_C14D233_eventHandler.selector,
        IWorld(world).pretty_C14D233_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberLogStep233VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberLogStep233VoxelVariantID;
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
