// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLogWall492VoxelID = bytes32(keccak256("oak_log_wall_492"));
bytes32 constant OakLogWall492VoxelVariantID = bytes32(keccak256("oak_log_wall_492"));

contract OakLogWall492VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLogWall492Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLogWall492VoxelVariantID, oakLogWall492Variant);

    bytes32[] memory oakLogWall492ChildVoxelTypes = new bytes32[](1);
    oakLogWall492ChildVoxelTypes[0] = OakLogWall492VoxelID;
    bytes32 baseVoxelTypeId = OakLogWall492VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Log Wall492",
      OakLogWall492VoxelID,
      baseVoxelTypeId,
      oakLogWall492ChildVoxelTypes,
      oakLogWall492ChildVoxelTypes,
      OakLogWall492VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C3492_enterWorld.selector,
        IWorld(world).pretty_C3492_exitWorld.selector,
        IWorld(world).pretty_C3492_variantSelector.selector,
        IWorld(world).pretty_C3492_activate.selector,
        IWorld(world).pretty_C3492_eventHandler.selector,
        IWorld(world).pretty_C3492_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLogWall492VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLogWall492VoxelVariantID;
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
