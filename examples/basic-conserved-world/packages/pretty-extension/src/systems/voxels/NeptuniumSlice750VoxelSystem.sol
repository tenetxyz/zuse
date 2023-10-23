// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant NeptuniumSlice750VoxelID = bytes32(keccak256("neptunium_slice_750"));
bytes32 constant NeptuniumSlice750VoxelVariantID = bytes32(keccak256("neptunium_slice_750"));

contract NeptuniumSlice750VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory neptuniumSlice750Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, NeptuniumSlice750VoxelVariantID, neptuniumSlice750Variant);

    bytes32[] memory neptuniumSlice750ChildVoxelTypes = new bytes32[](1);
    neptuniumSlice750ChildVoxelTypes[0] = NeptuniumSlice750VoxelID;
    bytes32 baseVoxelTypeId = NeptuniumSlice750VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Neptunium Slice750",
      NeptuniumSlice750VoxelID,
      baseVoxelTypeId,
      neptuniumSlice750ChildVoxelTypes,
      neptuniumSlice750ChildVoxelTypes,
      NeptuniumSlice750VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C28D750_enterWorld.selector,
        IWorld(world).pretty_C28D750_exitWorld.selector,
        IWorld(world).pretty_C28D750_variantSelector.selector,
        IWorld(world).pretty_C28D750_activate.selector,
        IWorld(world).pretty_C28D750_eventHandler.selector,
        IWorld(world).pretty_C28D750_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, NeptuniumSlice750VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return NeptuniumSlice750VoxelVariantID;
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
