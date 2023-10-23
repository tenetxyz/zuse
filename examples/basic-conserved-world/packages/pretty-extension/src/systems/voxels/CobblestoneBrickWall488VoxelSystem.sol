// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CobblestoneBrickWall488VoxelID = bytes32(keccak256("cobblestone_brick_wall_488"));
bytes32 constant CobblestoneBrickWall488VoxelVariantID = bytes32(keccak256("cobblestone_brick_wall_488"));

contract CobblestoneBrickWall488VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cobblestoneBrickWall488Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CobblestoneBrickWall488VoxelVariantID, cobblestoneBrickWall488Variant);

    bytes32[] memory cobblestoneBrickWall488ChildVoxelTypes = new bytes32[](1);
    cobblestoneBrickWall488ChildVoxelTypes[0] = CobblestoneBrickWall488VoxelID;
    bytes32 baseVoxelTypeId = CobblestoneBrickWall488VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cobblestone Brick Wall488",
      CobblestoneBrickWall488VoxelID,
      baseVoxelTypeId,
      cobblestoneBrickWall488ChildVoxelTypes,
      cobblestoneBrickWall488ChildVoxelTypes,
      CobblestoneBrickWall488VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C20D488_enterWorld.selector,
        IWorld(world).pretty_C20D488_exitWorld.selector,
        IWorld(world).pretty_C20D488_variantSelector.selector,
        IWorld(world).pretty_C20D488_activate.selector,
        IWorld(world).pretty_C20D488_eventHandler.selector,
        IWorld(world).pretty_C20D488_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CobblestoneBrickWall488VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CobblestoneBrickWall488VoxelVariantID;
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
