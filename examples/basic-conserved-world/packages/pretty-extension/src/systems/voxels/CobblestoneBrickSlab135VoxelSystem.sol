// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CobblestoneBrickSlab135VoxelID = bytes32(keccak256("cobblestone_brick_slab_135"));
bytes32 constant CobblestoneBrickSlab135VoxelVariantID = bytes32(keccak256("cobblestone_brick_slab_135"));

contract CobblestoneBrickSlab135VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cobblestoneBrickSlab135Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CobblestoneBrickSlab135VoxelVariantID, cobblestoneBrickSlab135Variant);

    bytes32[] memory cobblestoneBrickSlab135ChildVoxelTypes = new bytes32[](1);
    cobblestoneBrickSlab135ChildVoxelTypes[0] = CobblestoneBrickSlab135VoxelID;
    bytes32 baseVoxelTypeId = CobblestoneBrickSlab135VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cobblestone Brick Slab135",
      CobblestoneBrickSlab135VoxelID,
      baseVoxelTypeId,
      cobblestoneBrickSlab135ChildVoxelTypes,
      cobblestoneBrickSlab135ChildVoxelTypes,
      CobblestoneBrickSlab135VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C20D135_enterWorld.selector,
        IWorld(world).pretty_C20D135_exitWorld.selector,
        IWorld(world).pretty_C20D135_variantSelector.selector,
        IWorld(world).pretty_C20D135_activate.selector,
        IWorld(world).pretty_C20D135_eventHandler.selector,
        IWorld(world).pretty_C20D135_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CobblestoneBrickSlab135VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CobblestoneBrickSlab135VoxelVariantID;
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
