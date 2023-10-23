// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberFence320VoxelID = bytes32(keccak256("oak_lumber_fence_320"));
bytes32 constant OakLumberFence320VoxelVariantID = bytes32(keccak256("oak_lumber_fence_320"));

contract OakLumberFence320VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberFence320Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberFence320VoxelVariantID, oakLumberFence320Variant);

    bytes32[] memory oakLumberFence320ChildVoxelTypes = new bytes32[](1);
    oakLumberFence320ChildVoxelTypes[0] = OakLumberFence320VoxelID;
    bytes32 baseVoxelTypeId = OakLumberFence320VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Fence320",
      OakLumberFence320VoxelID,
      baseVoxelTypeId,
      oakLumberFence320ChildVoxelTypes,
      oakLumberFence320ChildVoxelTypes,
      OakLumberFence320VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D320_enterWorld.selector,
        IWorld(world).pretty_C31D320_exitWorld.selector,
        IWorld(world).pretty_C31D320_variantSelector.selector,
        IWorld(world).pretty_C31D320_activate.selector,
        IWorld(world).pretty_C31D320_eventHandler.selector,
        IWorld(world).pretty_C31D320_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberFence320VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberFence320VoxelVariantID;
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
