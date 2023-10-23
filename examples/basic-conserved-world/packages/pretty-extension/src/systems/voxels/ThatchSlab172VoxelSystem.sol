// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ThatchSlab172VoxelID = bytes32(keccak256("thatch_slab_172"));
bytes32 constant ThatchSlab172VoxelVariantID = bytes32(keccak256("thatch_slab_172"));

contract ThatchSlab172VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory thatchSlab172Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ThatchSlab172VoxelVariantID, thatchSlab172Variant);

    bytes32[] memory thatchSlab172ChildVoxelTypes = new bytes32[](1);
    thatchSlab172ChildVoxelTypes[0] = ThatchSlab172VoxelID;
    bytes32 baseVoxelTypeId = ThatchSlab172VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Thatch Slab172",
      ThatchSlab172VoxelID,
      baseVoxelTypeId,
      thatchSlab172ChildVoxelTypes,
      thatchSlab172ChildVoxelTypes,
      ThatchSlab172VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C63D172_enterWorld.selector,
        IWorld(world).pretty_C63D172_exitWorld.selector,
        IWorld(world).pretty_C63D172_variantSelector.selector,
        IWorld(world).pretty_C63D172_activate.selector,
        IWorld(world).pretty_C63D172_eventHandler.selector,
        IWorld(world).pretty_C63D172_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ThatchSlab172VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ThatchSlab172VoxelVariantID;
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
