// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberSlab171VoxelID = bytes32(keccak256("oak_lumber_slab_171"));
bytes32 constant OakLumberSlab171VoxelVariantID = bytes32(keccak256("oak_lumber_slab_171"));

contract OakLumberSlab171VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberSlab171Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberSlab171VoxelVariantID, oakLumberSlab171Variant);

    bytes32[] memory oakLumberSlab171ChildVoxelTypes = new bytes32[](1);
    oakLumberSlab171ChildVoxelTypes[0] = OakLumberSlab171VoxelID;
    bytes32 baseVoxelTypeId = OakLumberSlab171VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Slab171",
      OakLumberSlab171VoxelID,
      baseVoxelTypeId,
      oakLumberSlab171ChildVoxelTypes,
      oakLumberSlab171ChildVoxelTypes,
      OakLumberSlab171VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D171_enterWorld.selector,
        IWorld(world).pretty_C31D171_exitWorld.selector,
        IWorld(world).pretty_C31D171_variantSelector.selector,
        IWorld(world).pretty_C31D171_activate.selector,
        IWorld(world).pretty_C31D171_eventHandler.selector,
        IWorld(world).pretty_C31D171_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberSlab171VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberSlab171VoxelVariantID;
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
