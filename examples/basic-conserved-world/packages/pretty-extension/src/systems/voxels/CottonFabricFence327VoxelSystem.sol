// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricFence327VoxelID = bytes32(keccak256("cotton_fabric_fence_327"));
bytes32 constant CottonFabricFence327VoxelVariantID = bytes32(keccak256("cotton_fabric_fence_327"));

contract CottonFabricFence327VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricFence327Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricFence327VoxelVariantID, cottonFabricFence327Variant);

    bytes32[] memory cottonFabricFence327ChildVoxelTypes = new bytes32[](1);
    cottonFabricFence327ChildVoxelTypes[0] = CottonFabricFence327VoxelID;
    bytes32 baseVoxelTypeId = CottonFabricFence327VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Fence327",
      CottonFabricFence327VoxelID,
      baseVoxelTypeId,
      cottonFabricFence327ChildVoxelTypes,
      cottonFabricFence327ChildVoxelTypes,
      CottonFabricFence327VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D327_enterWorld.selector,
        IWorld(world).pretty_C38D327_exitWorld.selector,
        IWorld(world).pretty_C38D327_variantSelector.selector,
        IWorld(world).pretty_C38D327_activate.selector,
        IWorld(world).pretty_C38D327_eventHandler.selector,
        IWorld(world).pretty_C38D327_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricFence327VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricFence327VoxelVariantID;
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
