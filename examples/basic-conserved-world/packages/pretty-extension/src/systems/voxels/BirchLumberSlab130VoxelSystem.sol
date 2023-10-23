// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BirchLumberSlab130VoxelID = bytes32(keccak256("birch_lumber_slab_130"));
bytes32 constant BirchLumberSlab130VoxelVariantID = bytes32(keccak256("birch_lumber_slab_130"));

contract BirchLumberSlab130VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory birchLumberSlab130Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BirchLumberSlab130VoxelVariantID, birchLumberSlab130Variant);

    bytes32[] memory birchLumberSlab130ChildVoxelTypes = new bytes32[](1);
    birchLumberSlab130ChildVoxelTypes[0] = BirchLumberSlab130VoxelID;
    bytes32 baseVoxelTypeId = BirchLumberSlab130VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Birch Lumber Slab130",
      BirchLumberSlab130VoxelID,
      baseVoxelTypeId,
      birchLumberSlab130ChildVoxelTypes,
      birchLumberSlab130ChildVoxelTypes,
      BirchLumberSlab130VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C16D130_enterWorld.selector,
        IWorld(world).pretty_C16D130_exitWorld.selector,
        IWorld(world).pretty_C16D130_variantSelector.selector,
        IWorld(world).pretty_C16D130_activate.selector,
        IWorld(world).pretty_C16D130_eventHandler.selector,
        IWorld(world).pretty_C16D130_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BirchLumberSlab130VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BirchLumberSlab130VoxelVariantID;
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
