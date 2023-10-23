// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant HayFull64VoxelID = bytes32(keccak256("hay_full_64"));
bytes32 constant HayFull64VoxelVariantID = bytes32(keccak256("hay_full_64"));

contract HayFull64VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory hayFull64Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, HayFull64VoxelVariantID, hayFull64Variant);

    bytes32[] memory hayFull64ChildVoxelTypes = new bytes32[](1);
    hayFull64ChildVoxelTypes[0] = HayFull64VoxelID;
    bytes32 baseVoxelTypeId = HayFull64VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Hay Full64",
      HayFull64VoxelID,
      baseVoxelTypeId,
      hayFull64ChildVoxelTypes,
      hayFull64ChildVoxelTypes,
      HayFull64VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C35D64_enterWorld.selector,
        IWorld(world).pretty_C35D64_exitWorld.selector,
        IWorld(world).pretty_C35D64_variantSelector.selector,
        IWorld(world).pretty_C35D64_activate.selector,
        IWorld(world).pretty_C35D64_eventHandler.selector,
        IWorld(world).pretty_C35D64_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, HayFull64VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return HayFull64VoxelVariantID;
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
