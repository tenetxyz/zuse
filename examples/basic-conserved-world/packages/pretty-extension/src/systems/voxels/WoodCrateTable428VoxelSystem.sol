// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant WoodCrateTable428VoxelID = bytes32(keccak256("wood_crate_table_428"));
bytes32 constant WoodCrateTable428VoxelVariantID = bytes32(keccak256("wood_crate_table_428"));

contract WoodCrateTable428VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory woodCrateTable428Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, WoodCrateTable428VoxelVariantID, woodCrateTable428Variant);

    bytes32[] memory woodCrateTable428ChildVoxelTypes = new bytes32[](1);
    woodCrateTable428ChildVoxelTypes[0] = WoodCrateTable428VoxelID;
    bytes32 baseVoxelTypeId = WoodCrateTable428VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Wood Crate Table428",
      WoodCrateTable428VoxelID,
      baseVoxelTypeId,
      woodCrateTable428ChildVoxelTypes,
      woodCrateTable428ChildVoxelTypes,
      WoodCrateTable428VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C22D428_enterWorld.selector,
        IWorld(world).pretty_C22D428_exitWorld.selector,
        IWorld(world).pretty_C22D428_variantSelector.selector,
        IWorld(world).pretty_C22D428_activate.selector,
        IWorld(world).pretty_C22D428_eventHandler.selector,
        IWorld(world).pretty_C22D428_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, WoodCrateTable428VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return WoodCrateTable428VoxelVariantID;
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
