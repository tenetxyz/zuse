// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BirchStrippedLog261VoxelID = bytes32(keccak256("birch_stripped_log_261"));
bytes32 constant BirchStrippedLog261VoxelVariantID = bytes32(keccak256("birch_stripped_log_261"));

contract BirchStrippedLog261VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory birchStrippedLog261Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BirchStrippedLog261VoxelVariantID, birchStrippedLog261Variant);

    bytes32[] memory birchStrippedLog261ChildVoxelTypes = new bytes32[](1);
    birchStrippedLog261ChildVoxelTypes[0] = BirchStrippedLog261VoxelID;
    bytes32 baseVoxelTypeId = BirchStrippedLog261VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Birch Stripped Log261",
      BirchStrippedLog261VoxelID,
      baseVoxelTypeId,
      birchStrippedLog261ChildVoxelTypes,
      birchStrippedLog261ChildVoxelTypes,
      BirchStrippedLog261VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C71D261_enterWorld.selector,
        IWorld(world).pretty_C71D261_exitWorld.selector,
        IWorld(world).pretty_C71D261_variantSelector.selector,
        IWorld(world).pretty_C71D261_activate.selector,
        IWorld(world).pretty_C71D261_eventHandler.selector,
        IWorld(world).pretty_C71D261_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BirchStrippedLog261VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BirchStrippedLog261VoxelVariantID;
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
