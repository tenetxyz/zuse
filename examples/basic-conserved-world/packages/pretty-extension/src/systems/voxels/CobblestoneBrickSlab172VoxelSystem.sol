// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CobblestoneBrickSlab172VoxelID = bytes32(keccak256("cobblestone_brick_slab_172"));
bytes32 constant CobblestoneBrickSlab172VoxelVariantID = bytes32(keccak256("cobblestone_brick_slab_172"));

contract CobblestoneBrickSlab172VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cobblestoneBrickSlab172Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CobblestoneBrickSlab172VoxelVariantID, cobblestoneBrickSlab172Variant);

    bytes32[] memory cobblestoneBrickSlab172ChildVoxelTypes = new bytes32[](1);
    cobblestoneBrickSlab172ChildVoxelTypes[0] = CobblestoneBrickSlab172VoxelID;
    bytes32 baseVoxelTypeId = CobblestoneBrickSlab172VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cobblestone Brick Slab172",
      CobblestoneBrickSlab172VoxelID,
      baseVoxelTypeId,
      cobblestoneBrickSlab172ChildVoxelTypes,
      cobblestoneBrickSlab172ChildVoxelTypes,
      CobblestoneBrickSlab172VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C20D172_enterWorld.selector,
        IWorld(world).pretty_C20D172_exitWorld.selector,
        IWorld(world).pretty_C20D172_variantSelector.selector,
        IWorld(world).pretty_C20D172_activate.selector,
        IWorld(world).pretty_C20D172_eventHandler.selector,
        IWorld(world).pretty_C20D172_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CobblestoneBrickSlab172VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CobblestoneBrickSlab172VoxelVariantID;
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
