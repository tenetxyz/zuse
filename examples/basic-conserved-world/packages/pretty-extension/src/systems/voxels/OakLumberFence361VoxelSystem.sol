// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberFence361VoxelID = bytes32(keccak256("oak_lumber_fence_361"));
bytes32 constant OakLumberFence361VoxelVariantID = bytes32(keccak256("oak_lumber_fence_361"));

contract OakLumberFence361VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberFence361Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberFence361VoxelVariantID, oakLumberFence361Variant);

    bytes32[] memory oakLumberFence361ChildVoxelTypes = new bytes32[](1);
    oakLumberFence361ChildVoxelTypes[0] = OakLumberFence361VoxelID;
    bytes32 baseVoxelTypeId = OakLumberFence361VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Fence361",
      OakLumberFence361VoxelID,
      baseVoxelTypeId,
      oakLumberFence361ChildVoxelTypes,
      oakLumberFence361ChildVoxelTypes,
      OakLumberFence361VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D361_enterWorld.selector,
        IWorld(world).pretty_C31D361_exitWorld.selector,
        IWorld(world).pretty_C31D361_variantSelector.selector,
        IWorld(world).pretty_C31D361_activate.selector,
        IWorld(world).pretty_C31D361_eventHandler.selector,
        IWorld(world).pretty_C31D361_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberFence361VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberFence361VoxelVariantID;
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
