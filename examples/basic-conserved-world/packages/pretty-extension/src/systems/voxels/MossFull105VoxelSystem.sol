// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant MossFull105VoxelID = bytes32(keccak256("moss_full_105"));
bytes32 constant MossFull105VoxelVariantID = bytes32(keccak256("moss_full_105"));

contract MossFull105VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory mossFull105Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, MossFull105VoxelVariantID, mossFull105Variant);

    bytes32[] memory mossFull105ChildVoxelTypes = new bytes32[](1);
    mossFull105ChildVoxelTypes[0] = MossFull105VoxelID;
    bytes32 baseVoxelTypeId = MossFull105VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Moss Full105",
      MossFull105VoxelID,
      baseVoxelTypeId,
      mossFull105ChildVoxelTypes,
      mossFull105ChildVoxelTypes,
      MossFull105VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C40D105_enterWorld.selector,
        IWorld(world).pretty_C40D105_exitWorld.selector,
        IWorld(world).pretty_C40D105_variantSelector.selector,
        IWorld(world).pretty_C40D105_activate.selector,
        IWorld(world).pretty_C40D105_eventHandler.selector,
        IWorld(world).pretty_C40D105_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, MossFull105VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return MossFull105VoxelVariantID;
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
