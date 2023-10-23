// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BirchStrippedLog258VoxelID = bytes32(keccak256("birch_stripped_log_258"));
bytes32 constant BirchStrippedLog258VoxelVariantID = bytes32(keccak256("birch_stripped_log_258"));

contract BirchStrippedLog258VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory birchStrippedLog258Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BirchStrippedLog258VoxelVariantID, birchStrippedLog258Variant);

    bytes32[] memory birchStrippedLog258ChildVoxelTypes = new bytes32[](1);
    birchStrippedLog258ChildVoxelTypes[0] = BirchStrippedLog258VoxelID;
    bytes32 baseVoxelTypeId = BirchStrippedLog258VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Birch Stripped Log258",
      BirchStrippedLog258VoxelID,
      baseVoxelTypeId,
      birchStrippedLog258ChildVoxelTypes,
      birchStrippedLog258ChildVoxelTypes,
      BirchStrippedLog258VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C71D258_enterWorld.selector,
        IWorld(world).pretty_C71D258_exitWorld.selector,
        IWorld(world).pretty_C71D258_variantSelector.selector,
        IWorld(world).pretty_C71D258_activate.selector,
        IWorld(world).pretty_C71D258_eventHandler.selector,
        IWorld(world).pretty_C71D258_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BirchStrippedLog258VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BirchStrippedLog258VoxelVariantID;
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
