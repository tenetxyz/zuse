// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberStrippedStep238VoxelID = bytes32(keccak256("rubber_stripped_step_238"));
bytes32 constant RubberStrippedStep238VoxelVariantID = bytes32(keccak256("rubber_stripped_step_238"));

contract RubberStrippedStep238VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberStrippedStep238Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberStrippedStep238VoxelVariantID, rubberStrippedStep238Variant);

    bytes32[] memory rubberStrippedStep238ChildVoxelTypes = new bytes32[](1);
    rubberStrippedStep238ChildVoxelTypes[0] = RubberStrippedStep238VoxelID;
    bytes32 baseVoxelTypeId = RubberStrippedStep238VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Stripped Step238",
      RubberStrippedStep238VoxelID,
      baseVoxelTypeId,
      rubberStrippedStep238ChildVoxelTypes,
      rubberStrippedStep238ChildVoxelTypes,
      RubberStrippedStep238VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C75D238_enterWorld.selector,
        IWorld(world).pretty_C75D238_exitWorld.selector,
        IWorld(world).pretty_C75D238_variantSelector.selector,
        IWorld(world).pretty_C75D238_activate.selector,
        IWorld(world).pretty_C75D238_eventHandler.selector,
        IWorld(world).pretty_C75D238_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberStrippedStep238VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberStrippedStep238VoxelVariantID;
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
