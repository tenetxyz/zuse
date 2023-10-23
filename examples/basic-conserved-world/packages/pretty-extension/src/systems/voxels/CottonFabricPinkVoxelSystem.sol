// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricPinkVoxelID = bytes32(keccak256("cotton_fabric_pink"));
bytes32 constant CottonFabricPinkVoxelVariantID = bytes32(keccak256("cotton_fabric_pink"));

contract CottonFabricPinkVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricPinkVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricPinkVoxelVariantID, cottonFabricPinkVariant);

    bytes32[] memory cottonFabricPinkChildVoxelTypes = new bytes32[](1);
    cottonFabricPinkChildVoxelTypes[0] = CottonFabricPinkVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricPinkVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Pink",
      CottonFabricPinkVoxelID,
      baseVoxelTypeId,
      cottonFabricPinkChildVoxelTypes,
      cottonFabricPinkChildVoxelTypes,
      CottonFabricPinkVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38E7_enterWorld.selector,
        IWorld(world).pretty_C38E7_exitWorld.selector,
        IWorld(world).pretty_C38E7_variantSelector.selector,
        IWorld(world).pretty_C38E7_activate.selector,
        IWorld(world).pretty_C38E7_eventHandler.selector,
        IWorld(world).pretty_C38E7_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricPinkVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricPinkVoxelVariantID;
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
