// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricStep233OrangeVoxelID = bytes32(keccak256("cotton_fabric_step_233_orange"));
bytes32 constant CottonFabricStep233OrangeVoxelVariantID = bytes32(keccak256("cotton_fabric_step_233_orange"));

contract CottonFabricStep233OrangeVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricStep233OrangeVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricStep233OrangeVoxelVariantID, cottonFabricStep233OrangeVariant);

    bytes32[] memory cottonFabricStep233OrangeChildVoxelTypes = new bytes32[](1);
    cottonFabricStep233OrangeChildVoxelTypes[0] = CottonFabricStep233OrangeVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricStep233OrangeVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Step233 Orange",
      CottonFabricStep233OrangeVoxelID,
      baseVoxelTypeId,
      cottonFabricStep233OrangeChildVoxelTypes,
      cottonFabricStep233OrangeChildVoxelTypes,
      CottonFabricStep233OrangeVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D233E4_enterWorld.selector,
        IWorld(world).pretty_C38D233E4_exitWorld.selector,
        IWorld(world).pretty_C38D233E4_variantSelector.selector,
        IWorld(world).pretty_C38D233E4_activate.selector,
        IWorld(world).pretty_C38D233E4_eventHandler.selector,
        IWorld(world).pretty_C38D233E4_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricStep233OrangeVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricStep233OrangeVoxelVariantID;
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
