// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberStrippedStool1068VoxelID = bytes32(keccak256("rubber_stripped_stool_1068"));
bytes32 constant RubberStrippedStool1068VoxelVariantID = bytes32(keccak256("rubber_stripped_stool_1068"));

contract RubberStrippedStool1068VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberStrippedStool1068Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberStrippedStool1068VoxelVariantID, rubberStrippedStool1068Variant);

    bytes32[] memory rubberStrippedStool1068ChildVoxelTypes = new bytes32[](1);
    rubberStrippedStool1068ChildVoxelTypes[0] = RubberStrippedStool1068VoxelID;
    bytes32 baseVoxelTypeId = RubberStrippedStool1068VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Stripped Stool1068",
      RubberStrippedStool1068VoxelID,
      baseVoxelTypeId,
      rubberStrippedStool1068ChildVoxelTypes,
      rubberStrippedStool1068ChildVoxelTypes,
      RubberStrippedStool1068VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C75D1068_enterWorld.selector,
        IWorld(world).pretty_C75D1068_exitWorld.selector,
        IWorld(world).pretty_C75D1068_variantSelector.selector,
        IWorld(world).pretty_C75D1068_activate.selector,
        IWorld(world).pretty_C75D1068_eventHandler.selector,
        IWorld(world).pretty_C75D1068_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberStrippedStool1068VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberStrippedStool1068VoxelVariantID;
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
