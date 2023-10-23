// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant WoodCrateTable384VoxelID = bytes32(keccak256("wood_crate_table_384"));
bytes32 constant WoodCrateTable384VoxelVariantID = bytes32(keccak256("wood_crate_table_384"));

contract WoodCrateTable384VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory woodCrateTable384Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, WoodCrateTable384VoxelVariantID, woodCrateTable384Variant);

    bytes32[] memory woodCrateTable384ChildVoxelTypes = new bytes32[](1);
    woodCrateTable384ChildVoxelTypes[0] = WoodCrateTable384VoxelID;
    bytes32 baseVoxelTypeId = WoodCrateTable384VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Wood Crate Table384",
      WoodCrateTable384VoxelID,
      baseVoxelTypeId,
      woodCrateTable384ChildVoxelTypes,
      woodCrateTable384ChildVoxelTypes,
      WoodCrateTable384VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C22D384_enterWorld.selector,
        IWorld(world).pretty_C22D384_exitWorld.selector,
        IWorld(world).pretty_C22D384_variantSelector.selector,
        IWorld(world).pretty_C22D384_activate.selector,
        IWorld(world).pretty_C22D384_eventHandler.selector,
        IWorld(world).pretty_C22D384_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, WoodCrateTable384VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return WoodCrateTable384VoxelVariantID;
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
