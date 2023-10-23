// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberSlice706VoxelID = bytes32(keccak256("oak_lumber_slice_706"));
bytes32 constant OakLumberSlice706VoxelVariantID = bytes32(keccak256("oak_lumber_slice_706"));

contract OakLumberSlice706VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberSlice706Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberSlice706VoxelVariantID, oakLumberSlice706Variant);

    bytes32[] memory oakLumberSlice706ChildVoxelTypes = new bytes32[](1);
    oakLumberSlice706ChildVoxelTypes[0] = OakLumberSlice706VoxelID;
    bytes32 baseVoxelTypeId = OakLumberSlice706VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Slice706",
      OakLumberSlice706VoxelID,
      baseVoxelTypeId,
      oakLumberSlice706ChildVoxelTypes,
      oakLumberSlice706ChildVoxelTypes,
      OakLumberSlice706VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D706_enterWorld.selector,
        IWorld(world).pretty_C31D706_exitWorld.selector,
        IWorld(world).pretty_C31D706_variantSelector.selector,
        IWorld(world).pretty_C31D706_activate.selector,
        IWorld(world).pretty_C31D706_eventHandler.selector,
        IWorld(world).pretty_C31D706_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberSlice706VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberSlice706VoxelVariantID;
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
