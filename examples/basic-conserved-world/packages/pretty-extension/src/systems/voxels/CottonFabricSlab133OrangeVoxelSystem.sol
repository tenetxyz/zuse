// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricSlab133OrangeVoxelID = bytes32(keccak256("cotton_fabric_slab_133_orange"));
bytes32 constant CottonFabricSlab133OrangeVoxelVariantID = bytes32(keccak256("cotton_fabric_slab_133_orange"));

contract CottonFabricSlab133OrangeVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricSlab133OrangeVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricSlab133OrangeVoxelVariantID, cottonFabricSlab133OrangeVariant);

    bytes32[] memory cottonFabricSlab133OrangeChildVoxelTypes = new bytes32[](1);
    cottonFabricSlab133OrangeChildVoxelTypes[0] = CottonFabricSlab133OrangeVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricSlab133OrangeVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Slab133 Orange",
      CottonFabricSlab133OrangeVoxelID,
      baseVoxelTypeId,
      cottonFabricSlab133OrangeChildVoxelTypes,
      cottonFabricSlab133OrangeChildVoxelTypes,
      CottonFabricSlab133OrangeVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D133E4_enterWorld.selector,
        IWorld(world).pretty_C38D133E4_exitWorld.selector,
        IWorld(world).pretty_C38D133E4_variantSelector.selector,
        IWorld(world).pretty_C38D133E4_activate.selector,
        IWorld(world).pretty_C38D133E4_eventHandler.selector,
        IWorld(world).pretty_C38D133E4_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricSlab133OrangeVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricSlab133OrangeVoxelVariantID;
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
