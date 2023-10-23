// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberSlab174RedVoxelID = bytes32(keccak256("oak_lumber_slab_174_red"));
bytes32 constant OakLumberSlab174RedVoxelVariantID = bytes32(keccak256("oak_lumber_slab_174_red"));

contract OakLumberSlab174RedVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberSlab174RedVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberSlab174RedVoxelVariantID, oakLumberSlab174RedVariant);

    bytes32[] memory oakLumberSlab174RedChildVoxelTypes = new bytes32[](1);
    oakLumberSlab174RedChildVoxelTypes[0] = OakLumberSlab174RedVoxelID;
    bytes32 baseVoxelTypeId = OakLumberSlab174RedVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Slab174 Red",
      OakLumberSlab174RedVoxelID,
      baseVoxelTypeId,
      oakLumberSlab174RedChildVoxelTypes,
      oakLumberSlab174RedChildVoxelTypes,
      OakLumberSlab174RedVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D174E2_enterWorld.selector,
        IWorld(world).pretty_C31D174E2_exitWorld.selector,
        IWorld(world).pretty_C31D174E2_variantSelector.selector,
        IWorld(world).pretty_C31D174E2_activate.selector,
        IWorld(world).pretty_C31D174E2_eventHandler.selector,
        IWorld(world).pretty_C31D174E2_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberSlab174RedVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberSlab174RedVoxelVariantID;
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
