// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CobblestoneBrickFence320VoxelID = bytes32(keccak256("cobblestone_brick_fence_320"));
bytes32 constant CobblestoneBrickFence320VoxelVariantID = bytes32(keccak256("cobblestone_brick_fence_320"));

contract CobblestoneBrickFence320VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cobblestoneBrickFence320Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CobblestoneBrickFence320VoxelVariantID, cobblestoneBrickFence320Variant);

    bytes32[] memory cobblestoneBrickFence320ChildVoxelTypes = new bytes32[](1);
    cobblestoneBrickFence320ChildVoxelTypes[0] = CobblestoneBrickFence320VoxelID;
    bytes32 baseVoxelTypeId = CobblestoneBrickFence320VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cobblestone Brick Fence320",
      CobblestoneBrickFence320VoxelID,
      baseVoxelTypeId,
      cobblestoneBrickFence320ChildVoxelTypes,
      cobblestoneBrickFence320ChildVoxelTypes,
      CobblestoneBrickFence320VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C20D320_enterWorld.selector,
        IWorld(world).pretty_C20D320_exitWorld.selector,
        IWorld(world).pretty_C20D320_variantSelector.selector,
        IWorld(world).pretty_C20D320_activate.selector,
        IWorld(world).pretty_C20D320_eventHandler.selector,
        IWorld(world).pretty_C20D320_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CobblestoneBrickFence320VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CobblestoneBrickFence320VoxelVariantID;
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
