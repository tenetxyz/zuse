// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricSlab130WhiteVoxelID = bytes32(keccak256("cotton_fabric_slab_130_white"));
bytes32 constant CottonFabricSlab130WhiteVoxelVariantID = bytes32(keccak256("cotton_fabric_slab_130_white"));

contract CottonFabricSlab130WhiteVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricSlab130WhiteVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricSlab130WhiteVoxelVariantID, cottonFabricSlab130WhiteVariant);

    bytes32[] memory cottonFabricSlab130WhiteChildVoxelTypes = new bytes32[](1);
    cottonFabricSlab130WhiteChildVoxelTypes[0] = CottonFabricSlab130WhiteVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricSlab130WhiteVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Slab130 White",
      CottonFabricSlab130WhiteVoxelID,
      baseVoxelTypeId,
      cottonFabricSlab130WhiteChildVoxelTypes,
      cottonFabricSlab130WhiteChildVoxelTypes,
      CottonFabricSlab130WhiteVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D130E5_enterWorld.selector,
        IWorld(world).pretty_C38D130E5_exitWorld.selector,
        IWorld(world).pretty_C38D130E5_variantSelector.selector,
        IWorld(world).pretty_C38D130E5_activate.selector,
        IWorld(world).pretty_C38D130E5_eventHandler.selector,
        IWorld(world).pretty_C38D130E5_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricSlab130WhiteVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricSlab130WhiteVoxelVariantID;
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
