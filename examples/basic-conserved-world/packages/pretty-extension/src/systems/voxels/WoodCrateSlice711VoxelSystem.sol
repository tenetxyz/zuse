// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant WoodCrateSlice711VoxelID = bytes32(keccak256("wood_crate_slice_711"));
bytes32 constant WoodCrateSlice711VoxelVariantID = bytes32(keccak256("wood_crate_slice_711"));

contract WoodCrateSlice711VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory woodCrateSlice711Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, WoodCrateSlice711VoxelVariantID, woodCrateSlice711Variant);

    bytes32[] memory woodCrateSlice711ChildVoxelTypes = new bytes32[](1);
    woodCrateSlice711ChildVoxelTypes[0] = WoodCrateSlice711VoxelID;
    bytes32 baseVoxelTypeId = WoodCrateSlice711VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Wood Crate Slice711",
      WoodCrateSlice711VoxelID,
      baseVoxelTypeId,
      woodCrateSlice711ChildVoxelTypes,
      woodCrateSlice711ChildVoxelTypes,
      WoodCrateSlice711VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C22D711_enterWorld.selector,
        IWorld(world).pretty_C22D711_exitWorld.selector,
        IWorld(world).pretty_C22D711_variantSelector.selector,
        IWorld(world).pretty_C22D711_activate.selector,
        IWorld(world).pretty_C22D711_eventHandler.selector,
        IWorld(world).pretty_C22D711_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, WoodCrateSlice711VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return WoodCrateSlice711VoxelVariantID;
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
