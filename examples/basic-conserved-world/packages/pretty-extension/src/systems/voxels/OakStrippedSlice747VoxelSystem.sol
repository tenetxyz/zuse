// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakStrippedSlice747VoxelID = bytes32(keccak256("oak_stripped_slice_747"));
bytes32 constant OakStrippedSlice747VoxelVariantID = bytes32(keccak256("oak_stripped_slice_747"));

contract OakStrippedSlice747VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakStrippedSlice747Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakStrippedSlice747VoxelVariantID, oakStrippedSlice747Variant);

    bytes32[] memory oakStrippedSlice747ChildVoxelTypes = new bytes32[](1);
    oakStrippedSlice747ChildVoxelTypes[0] = OakStrippedSlice747VoxelID;
    bytes32 baseVoxelTypeId = OakStrippedSlice747VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Stripped Slice747",
      OakStrippedSlice747VoxelID,
      baseVoxelTypeId,
      oakStrippedSlice747ChildVoxelTypes,
      oakStrippedSlice747ChildVoxelTypes,
      OakStrippedSlice747VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C73D747_enterWorld.selector,
        IWorld(world).pretty_C73D747_exitWorld.selector,
        IWorld(world).pretty_C73D747_variantSelector.selector,
        IWorld(world).pretty_C73D747_activate.selector,
        IWorld(world).pretty_C73D747_eventHandler.selector,
        IWorld(world).pretty_C73D747_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakStrippedSlice747VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakStrippedSlice747VoxelVariantID;
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
