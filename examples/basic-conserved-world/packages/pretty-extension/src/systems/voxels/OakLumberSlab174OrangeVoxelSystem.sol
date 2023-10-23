// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberSlab174OrangeVoxelID = bytes32(keccak256("oak_lumber_slab_174_orange"));
bytes32 constant OakLumberSlab174OrangeVoxelVariantID = bytes32(keccak256("oak_lumber_slab_174_orange"));

contract OakLumberSlab174OrangeVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberSlab174OrangeVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberSlab174OrangeVoxelVariantID, oakLumberSlab174OrangeVariant);

    bytes32[] memory oakLumberSlab174OrangeChildVoxelTypes = new bytes32[](1);
    oakLumberSlab174OrangeChildVoxelTypes[0] = OakLumberSlab174OrangeVoxelID;
    bytes32 baseVoxelTypeId = OakLumberSlab174OrangeVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Slab174 Orange",
      OakLumberSlab174OrangeVoxelID,
      baseVoxelTypeId,
      oakLumberSlab174OrangeChildVoxelTypes,
      oakLumberSlab174OrangeChildVoxelTypes,
      OakLumberSlab174OrangeVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D174E4_enterWorld.selector,
        IWorld(world).pretty_C31D174E4_exitWorld.selector,
        IWorld(world).pretty_C31D174E4_variantSelector.selector,
        IWorld(world).pretty_C31D174E4_activate.selector,
        IWorld(world).pretty_C31D174E4_eventHandler.selector,
        IWorld(world).pretty_C31D174E4_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberSlab174OrangeVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberSlab174OrangeVoxelVariantID;
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
