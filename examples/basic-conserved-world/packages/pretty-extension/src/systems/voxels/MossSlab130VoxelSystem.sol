// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant MossSlab130VoxelID = bytes32(keccak256("moss_slab_130"));
bytes32 constant MossSlab130VoxelVariantID = bytes32(keccak256("moss_slab_130"));

contract MossSlab130VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory mossSlab130Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, MossSlab130VoxelVariantID, mossSlab130Variant);

    bytes32[] memory mossSlab130ChildVoxelTypes = new bytes32[](1);
    mossSlab130ChildVoxelTypes[0] = MossSlab130VoxelID;
    bytes32 baseVoxelTypeId = MossSlab130VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Moss Slab130",
      MossSlab130VoxelID,
      baseVoxelTypeId,
      mossSlab130ChildVoxelTypes,
      mossSlab130ChildVoxelTypes,
      MossSlab130VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C40D130_enterWorld.selector,
        IWorld(world).pretty_C40D130_exitWorld.selector,
        IWorld(world).pretty_C40D130_variantSelector.selector,
        IWorld(world).pretty_C40D130_activate.selector,
        IWorld(world).pretty_C40D130_eventHandler.selector,
        IWorld(world).pretty_C40D130_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, MossSlab130VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return MossSlab130VoxelVariantID;
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
