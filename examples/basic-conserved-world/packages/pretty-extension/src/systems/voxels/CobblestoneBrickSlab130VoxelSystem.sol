// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CobblestoneBrickSlab130VoxelID = bytes32(keccak256("cobblestone_brick_slab_130"));
bytes32 constant CobblestoneBrickSlab130VoxelVariantID = bytes32(keccak256("cobblestone_brick_slab_130"));

contract CobblestoneBrickSlab130VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cobblestoneBrickSlab130Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CobblestoneBrickSlab130VoxelVariantID, cobblestoneBrickSlab130Variant);

    bytes32[] memory cobblestoneBrickSlab130ChildVoxelTypes = new bytes32[](1);
    cobblestoneBrickSlab130ChildVoxelTypes[0] = CobblestoneBrickSlab130VoxelID;
    bytes32 baseVoxelTypeId = CobblestoneBrickSlab130VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cobblestone Brick Slab130",
      CobblestoneBrickSlab130VoxelID,
      baseVoxelTypeId,
      cobblestoneBrickSlab130ChildVoxelTypes,
      cobblestoneBrickSlab130ChildVoxelTypes,
      CobblestoneBrickSlab130VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C20D130_enterWorld.selector,
        IWorld(world).pretty_C20D130_exitWorld.selector,
        IWorld(world).pretty_C20D130_variantSelector.selector,
        IWorld(world).pretty_C20D130_activate.selector,
        IWorld(world).pretty_C20D130_eventHandler.selector,
        IWorld(world).pretty_C20D130_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CobblestoneBrickSlab130VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CobblestoneBrickSlab130VoxelVariantID;
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
