// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant EmberstoneFull64VoxelID = bytes32(keccak256("emberstone_full_64"));
bytes32 constant EmberstoneFull64VoxelVariantID = bytes32(keccak256("emberstone_full_64"));

contract EmberstoneFull64VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory emberstoneFull64Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, EmberstoneFull64VoxelVariantID, emberstoneFull64Variant);

    bytes32[] memory emberstoneFull64ChildVoxelTypes = new bytes32[](1);
    emberstoneFull64ChildVoxelTypes[0] = EmberstoneFull64VoxelID;
    bytes32 baseVoxelTypeId = EmberstoneFull64VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Emberstone Full64",
      EmberstoneFull64VoxelID,
      baseVoxelTypeId,
      emberstoneFull64ChildVoxelTypes,
      emberstoneFull64ChildVoxelTypes,
      EmberstoneFull64VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C65D64_enterWorld.selector,
        IWorld(world).pretty_C65D64_exitWorld.selector,
        IWorld(world).pretty_C65D64_variantSelector.selector,
        IWorld(world).pretty_C65D64_activate.selector,
        IWorld(world).pretty_C65D64_eventHandler.selector,
        IWorld(world).pretty_C65D64_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, EmberstoneFull64VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return EmberstoneFull64VoxelVariantID;
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
