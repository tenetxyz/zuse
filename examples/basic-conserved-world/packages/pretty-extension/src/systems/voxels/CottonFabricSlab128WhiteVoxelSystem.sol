// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricSlab128WhiteVoxelID = bytes32(keccak256("cotton_fabric_slab_128_white"));
bytes32 constant CottonFabricSlab128WhiteVoxelVariantID = bytes32(keccak256("cotton_fabric_slab_128_white"));

contract CottonFabricSlab128WhiteVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricSlab128WhiteVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricSlab128WhiteVoxelVariantID, cottonFabricSlab128WhiteVariant);

    bytes32[] memory cottonFabricSlab128WhiteChildVoxelTypes = new bytes32[](1);
    cottonFabricSlab128WhiteChildVoxelTypes[0] = CottonFabricSlab128WhiteVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricSlab128WhiteVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Slab128 White",
      CottonFabricSlab128WhiteVoxelID,
      baseVoxelTypeId,
      cottonFabricSlab128WhiteChildVoxelTypes,
      cottonFabricSlab128WhiteChildVoxelTypes,
      CottonFabricSlab128WhiteVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D128E5_enterWorld.selector,
        IWorld(world).pretty_C38D128E5_exitWorld.selector,
        IWorld(world).pretty_C38D128E5_variantSelector.selector,
        IWorld(world).pretty_C38D128E5_activate.selector,
        IWorld(world).pretty_C38D128E5_eventHandler.selector,
        IWorld(world).pretty_C38D128E5_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricSlab128WhiteVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricSlab128WhiteVoxelVariantID;
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
