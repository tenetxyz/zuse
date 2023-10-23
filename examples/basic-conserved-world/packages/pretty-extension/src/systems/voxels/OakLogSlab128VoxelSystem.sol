// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLogSlab128VoxelID = bytes32(keccak256("oak_log_slab_128"));
bytes32 constant OakLogSlab128VoxelVariantID = bytes32(keccak256("oak_log_slab_128"));

contract OakLogSlab128VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLogSlab128Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLogSlab128VoxelVariantID, oakLogSlab128Variant);

    bytes32[] memory oakLogSlab128ChildVoxelTypes = new bytes32[](1);
    oakLogSlab128ChildVoxelTypes[0] = OakLogSlab128VoxelID;
    bytes32 baseVoxelTypeId = OakLogSlab128VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Log Slab128",
      OakLogSlab128VoxelID,
      baseVoxelTypeId,
      oakLogSlab128ChildVoxelTypes,
      oakLogSlab128ChildVoxelTypes,
      OakLogSlab128VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C3D128_enterWorld.selector,
        IWorld(world).pretty_C3D128_exitWorld.selector,
        IWorld(world).pretty_C3D128_variantSelector.selector,
        IWorld(world).pretty_C3D128_activate.selector,
        IWorld(world).pretty_C3D128_eventHandler.selector,
        IWorld(world).pretty_C3D128_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLogSlab128VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLogSlab128VoxelVariantID;
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
