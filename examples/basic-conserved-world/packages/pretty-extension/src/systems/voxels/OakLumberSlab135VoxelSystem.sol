// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberSlab135VoxelID = bytes32(keccak256("oak_lumber_slab_135"));
bytes32 constant OakLumberSlab135VoxelVariantID = bytes32(keccak256("oak_lumber_slab_135"));

contract OakLumberSlab135VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberSlab135Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberSlab135VoxelVariantID, oakLumberSlab135Variant);

    bytes32[] memory oakLumberSlab135ChildVoxelTypes = new bytes32[](1);
    oakLumberSlab135ChildVoxelTypes[0] = OakLumberSlab135VoxelID;
    bytes32 baseVoxelTypeId = OakLumberSlab135VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Slab135",
      OakLumberSlab135VoxelID,
      baseVoxelTypeId,
      oakLumberSlab135ChildVoxelTypes,
      oakLumberSlab135ChildVoxelTypes,
      OakLumberSlab135VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D135_enterWorld.selector,
        IWorld(world).pretty_C31D135_exitWorld.selector,
        IWorld(world).pretty_C31D135_variantSelector.selector,
        IWorld(world).pretty_C31D135_activate.selector,
        IWorld(world).pretty_C31D135_eventHandler.selector,
        IWorld(world).pretty_C31D135_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberSlab135VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberSlab135VoxelVariantID;
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
