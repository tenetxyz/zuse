// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricSlab174VoxelID = bytes32(keccak256("cotton_fabric_slab_174"));
bytes32 constant CottonFabricSlab174VoxelVariantID = bytes32(keccak256("cotton_fabric_slab_174"));

contract CottonFabricSlab174VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricSlab174Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricSlab174VoxelVariantID, cottonFabricSlab174Variant);

    bytes32[] memory cottonFabricSlab174ChildVoxelTypes = new bytes32[](1);
    cottonFabricSlab174ChildVoxelTypes[0] = CottonFabricSlab174VoxelID;
    bytes32 baseVoxelTypeId = CottonFabricSlab174VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Slab174",
      CottonFabricSlab174VoxelID,
      baseVoxelTypeId,
      cottonFabricSlab174ChildVoxelTypes,
      cottonFabricSlab174ChildVoxelTypes,
      CottonFabricSlab174VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D174_enterWorld.selector,
        IWorld(world).pretty_C38D174_exitWorld.selector,
        IWorld(world).pretty_C38D174_variantSelector.selector,
        IWorld(world).pretty_C38D174_activate.selector,
        IWorld(world).pretty_C38D174_eventHandler.selector,
        IWorld(world).pretty_C38D174_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricSlab174VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricSlab174VoxelVariantID;
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
