// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant MoonstoneSlice706VoxelID = bytes32(keccak256("moonstone_slice_706"));
bytes32 constant MoonstoneSlice706VoxelVariantID = bytes32(keccak256("moonstone_slice_706"));

contract MoonstoneSlice706VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory moonstoneSlice706Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, MoonstoneSlice706VoxelVariantID, moonstoneSlice706Variant);

    bytes32[] memory moonstoneSlice706ChildVoxelTypes = new bytes32[](1);
    moonstoneSlice706ChildVoxelTypes[0] = MoonstoneSlice706VoxelID;
    bytes32 baseVoxelTypeId = MoonstoneSlice706VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Moonstone Slice706",
      MoonstoneSlice706VoxelID,
      baseVoxelTypeId,
      moonstoneSlice706ChildVoxelTypes,
      moonstoneSlice706ChildVoxelTypes,
      MoonstoneSlice706VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C67D706_enterWorld.selector,
        IWorld(world).pretty_C67D706_exitWorld.selector,
        IWorld(world).pretty_C67D706_variantSelector.selector,
        IWorld(world).pretty_C67D706_activate.selector,
        IWorld(world).pretty_C67D706_eventHandler.selector,
        IWorld(world).pretty_C67D706_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, MoonstoneSlice706VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return MoonstoneSlice706VoxelVariantID;
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
