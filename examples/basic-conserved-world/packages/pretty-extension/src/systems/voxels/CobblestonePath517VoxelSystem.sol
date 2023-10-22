// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CobblestonePath517VoxelID = bytes32(keccak256("cobblestone_path_517"));
bytes32 constant CobblestonePath517VoxelVariantID = bytes32(keccak256("cobblestone_path_517"));

contract CobblestonePath517VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cobblestonePath517Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CobblestonePath517VoxelVariantID, cobblestonePath517Variant);

    bytes32[] memory cobblestonePath517ChildVoxelTypes = new bytes32[](1);
    cobblestonePath517ChildVoxelTypes[0] = CobblestonePath517VoxelID;
    bytes32 baseVoxelTypeId = CobblestonePath517VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cobblestone Path517",
      CobblestonePath517VoxelID,
      baseVoxelTypeId,
      cobblestonePath517ChildVoxelTypes,
      cobblestonePath517ChildVoxelTypes,
      CobblestonePath517VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C5517_enterWorld.selector,
        IWorld(world).pretty_C5517_exitWorld.selector,
        IWorld(world).pretty_C5517_variantSelector.selector,
        IWorld(world).pretty_C5517_activate.selector,
        IWorld(world).pretty_C5517_eventHandler.selector,
        IWorld(world).pretty_C5517_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CobblestonePath517VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CobblestonePath517VoxelVariantID;
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
