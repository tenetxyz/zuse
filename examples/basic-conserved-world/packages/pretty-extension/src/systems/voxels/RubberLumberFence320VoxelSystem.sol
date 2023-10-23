// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberLumberFence320VoxelID = bytes32(keccak256("rubber_lumber_fence_320"));
bytes32 constant RubberLumberFence320VoxelVariantID = bytes32(keccak256("rubber_lumber_fence_320"));

contract RubberLumberFence320VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberLumberFence320Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberLumberFence320VoxelVariantID, rubberLumberFence320Variant);

    bytes32[] memory rubberLumberFence320ChildVoxelTypes = new bytes32[](1);
    rubberLumberFence320ChildVoxelTypes[0] = RubberLumberFence320VoxelID;
    bytes32 baseVoxelTypeId = RubberLumberFence320VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Lumber Fence320",
      RubberLumberFence320VoxelID,
      baseVoxelTypeId,
      rubberLumberFence320ChildVoxelTypes,
      rubberLumberFence320ChildVoxelTypes,
      RubberLumberFence320VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C34D320_enterWorld.selector,
        IWorld(world).pretty_C34D320_exitWorld.selector,
        IWorld(world).pretty_C34D320_variantSelector.selector,
        IWorld(world).pretty_C34D320_activate.selector,
        IWorld(world).pretty_C34D320_eventHandler.selector,
        IWorld(world).pretty_C34D320_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberLumberFence320VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberLumberFence320VoxelVariantID;
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
