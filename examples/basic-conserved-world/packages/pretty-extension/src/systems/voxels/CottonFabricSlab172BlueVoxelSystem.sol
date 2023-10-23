// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricSlab172BlueVoxelID = bytes32(keccak256("cotton_fabric_slab_172_blue"));
bytes32 constant CottonFabricSlab172BlueVoxelVariantID = bytes32(keccak256("cotton_fabric_slab_172_blue"));

contract CottonFabricSlab172BlueVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricSlab172BlueVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricSlab172BlueVoxelVariantID, cottonFabricSlab172BlueVariant);

    bytes32[] memory cottonFabricSlab172BlueChildVoxelTypes = new bytes32[](1);
    cottonFabricSlab172BlueChildVoxelTypes[0] = CottonFabricSlab172BlueVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricSlab172BlueVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Slab172 Blue",
      CottonFabricSlab172BlueVoxelID,
      baseVoxelTypeId,
      cottonFabricSlab172BlueChildVoxelTypes,
      cottonFabricSlab172BlueChildVoxelTypes,
      CottonFabricSlab172BlueVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D172E1_enterWorld.selector,
        IWorld(world).pretty_C38D172E1_exitWorld.selector,
        IWorld(world).pretty_C38D172E1_variantSelector.selector,
        IWorld(world).pretty_C38D172E1_activate.selector,
        IWorld(world).pretty_C38D172E1_eventHandler.selector,
        IWorld(world).pretty_C38D172E1_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricSlab172BlueVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricSlab172BlueVoxelVariantID;
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
