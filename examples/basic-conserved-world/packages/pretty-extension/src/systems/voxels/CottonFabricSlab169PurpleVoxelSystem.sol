// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricSlab169PurpleVoxelID = bytes32(keccak256("cotton_fabric_slab_169_purple"));
bytes32 constant CottonFabricSlab169PurpleVoxelVariantID = bytes32(keccak256("cotton_fabric_slab_169_purple"));

contract CottonFabricSlab169PurpleVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricSlab169PurpleVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricSlab169PurpleVoxelVariantID, cottonFabricSlab169PurpleVariant);

    bytes32[] memory cottonFabricSlab169PurpleChildVoxelTypes = new bytes32[](1);
    cottonFabricSlab169PurpleChildVoxelTypes[0] = CottonFabricSlab169PurpleVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricSlab169PurpleVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Slab169 Purple",
      CottonFabricSlab169PurpleVoxelID,
      baseVoxelTypeId,
      cottonFabricSlab169PurpleChildVoxelTypes,
      cottonFabricSlab169PurpleChildVoxelTypes,
      CottonFabricSlab169PurpleVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D169E6_enterWorld.selector,
        IWorld(world).pretty_C38D169E6_exitWorld.selector,
        IWorld(world).pretty_C38D169E6_variantSelector.selector,
        IWorld(world).pretty_C38D169E6_activate.selector,
        IWorld(world).pretty_C38D169E6_eventHandler.selector,
        IWorld(world).pretty_C38D169E6_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricSlab169PurpleVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricSlab169PurpleVoxelVariantID;
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
