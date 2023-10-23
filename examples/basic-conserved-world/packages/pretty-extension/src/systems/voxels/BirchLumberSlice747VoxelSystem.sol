// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BirchLumberSlice747VoxelID = bytes32(keccak256("birch_lumber_slice_747"));
bytes32 constant BirchLumberSlice747VoxelVariantID = bytes32(keccak256("birch_lumber_slice_747"));

contract BirchLumberSlice747VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory birchLumberSlice747Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BirchLumberSlice747VoxelVariantID, birchLumberSlice747Variant);

    bytes32[] memory birchLumberSlice747ChildVoxelTypes = new bytes32[](1);
    birchLumberSlice747ChildVoxelTypes[0] = BirchLumberSlice747VoxelID;
    bytes32 baseVoxelTypeId = BirchLumberSlice747VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Birch Lumber Slice747",
      BirchLumberSlice747VoxelID,
      baseVoxelTypeId,
      birchLumberSlice747ChildVoxelTypes,
      birchLumberSlice747ChildVoxelTypes,
      BirchLumberSlice747VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C16D747_enterWorld.selector,
        IWorld(world).pretty_C16D747_exitWorld.selector,
        IWorld(world).pretty_C16D747_variantSelector.selector,
        IWorld(world).pretty_C16D747_activate.selector,
        IWorld(world).pretty_C16D747_eventHandler.selector,
        IWorld(world).pretty_C16D747_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BirchLumberSlice747VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BirchLumberSlice747VoxelVariantID;
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
