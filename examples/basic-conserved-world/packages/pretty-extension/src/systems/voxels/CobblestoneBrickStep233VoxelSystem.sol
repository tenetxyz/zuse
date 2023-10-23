// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CobblestoneBrickStep233VoxelID = bytes32(keccak256("cobblestone_brick_step_233"));
bytes32 constant CobblestoneBrickStep233VoxelVariantID = bytes32(keccak256("cobblestone_brick_step_233"));

contract CobblestoneBrickStep233VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cobblestoneBrickStep233Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CobblestoneBrickStep233VoxelVariantID, cobblestoneBrickStep233Variant);

    bytes32[] memory cobblestoneBrickStep233ChildVoxelTypes = new bytes32[](1);
    cobblestoneBrickStep233ChildVoxelTypes[0] = CobblestoneBrickStep233VoxelID;
    bytes32 baseVoxelTypeId = CobblestoneBrickStep233VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cobblestone Brick Step233",
      CobblestoneBrickStep233VoxelID,
      baseVoxelTypeId,
      cobblestoneBrickStep233ChildVoxelTypes,
      cobblestoneBrickStep233ChildVoxelTypes,
      CobblestoneBrickStep233VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C20D233_enterWorld.selector,
        IWorld(world).pretty_C20D233_exitWorld.selector,
        IWorld(world).pretty_C20D233_variantSelector.selector,
        IWorld(world).pretty_C20D233_activate.selector,
        IWorld(world).pretty_C20D233_eventHandler.selector,
        IWorld(world).pretty_C20D233_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CobblestoneBrickStep233VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CobblestoneBrickStep233VoxelVariantID;
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
