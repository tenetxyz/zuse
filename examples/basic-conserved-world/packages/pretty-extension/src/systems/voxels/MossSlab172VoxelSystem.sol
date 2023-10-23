// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant MossSlab172VoxelID = bytes32(keccak256("moss_slab_172"));
bytes32 constant MossSlab172VoxelVariantID = bytes32(keccak256("moss_slab_172"));

contract MossSlab172VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory mossSlab172Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, MossSlab172VoxelVariantID, mossSlab172Variant);

    bytes32[] memory mossSlab172ChildVoxelTypes = new bytes32[](1);
    mossSlab172ChildVoxelTypes[0] = MossSlab172VoxelID;
    bytes32 baseVoxelTypeId = MossSlab172VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Moss Slab172",
      MossSlab172VoxelID,
      baseVoxelTypeId,
      mossSlab172ChildVoxelTypes,
      mossSlab172ChildVoxelTypes,
      MossSlab172VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C40D172_enterWorld.selector,
        IWorld(world).pretty_C40D172_exitWorld.selector,
        IWorld(world).pretty_C40D172_variantSelector.selector,
        IWorld(world).pretty_C40D172_activate.selector,
        IWorld(world).pretty_C40D172_eventHandler.selector,
        IWorld(world).pretty_C40D172_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, MossSlab172VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return MossSlab172VoxelVariantID;
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
