// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayLog261VoxelID = bytes32(keccak256("clay_log_261"));
bytes32 constant ClayLog261VoxelVariantID = bytes32(keccak256("clay_log_261"));

contract ClayLog261VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayLog261Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayLog261VoxelVariantID, clayLog261Variant);

    bytes32[] memory clayLog261ChildVoxelTypes = new bytes32[](1);
    clayLog261ChildVoxelTypes[0] = ClayLog261VoxelID;
    bytes32 baseVoxelTypeId = ClayLog261VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Log261",
      ClayLog261VoxelID,
      baseVoxelTypeId,
      clayLog261ChildVoxelTypes,
      clayLog261ChildVoxelTypes,
      ClayLog261VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C17D261_enterWorld.selector,
        IWorld(world).pretty_C17D261_exitWorld.selector,
        IWorld(world).pretty_C17D261_variantSelector.selector,
        IWorld(world).pretty_C17D261_activate.selector,
        IWorld(world).pretty_C17D261_eventHandler.selector,
        IWorld(world).pretty_C17D261_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayLog261VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayLog261VoxelVariantID;
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
