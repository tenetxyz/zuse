// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricStool1065VoxelID = bytes32(keccak256("cotton_fabric_stool_1065"));
bytes32 constant CottonFabricStool1065VoxelVariantID = bytes32(keccak256("cotton_fabric_stool_1065"));

contract CottonFabricStool1065VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricStool1065Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricStool1065VoxelVariantID, cottonFabricStool1065Variant);

    bytes32[] memory cottonFabricStool1065ChildVoxelTypes = new bytes32[](1);
    cottonFabricStool1065ChildVoxelTypes[0] = CottonFabricStool1065VoxelID;
    bytes32 baseVoxelTypeId = CottonFabricStool1065VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Stool1065",
      CottonFabricStool1065VoxelID,
      baseVoxelTypeId,
      cottonFabricStool1065ChildVoxelTypes,
      cottonFabricStool1065ChildVoxelTypes,
      CottonFabricStool1065VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D1065_enterWorld.selector,
        IWorld(world).pretty_C38D1065_exitWorld.selector,
        IWorld(world).pretty_C38D1065_variantSelector.selector,
        IWorld(world).pretty_C38D1065_activate.selector,
        IWorld(world).pretty_C38D1065_eventHandler.selector,
        IWorld(world).pretty_C38D1065_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricStool1065VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricStool1065VoxelVariantID;
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
