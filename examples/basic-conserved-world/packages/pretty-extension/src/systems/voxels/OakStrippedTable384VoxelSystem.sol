// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakStrippedTable384VoxelID = bytes32(keccak256("oak_stripped_table_384"));
bytes32 constant OakStrippedTable384VoxelVariantID = bytes32(keccak256("oak_stripped_table_384"));

contract OakStrippedTable384VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakStrippedTable384Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakStrippedTable384VoxelVariantID, oakStrippedTable384Variant);

    bytes32[] memory oakStrippedTable384ChildVoxelTypes = new bytes32[](1);
    oakStrippedTable384ChildVoxelTypes[0] = OakStrippedTable384VoxelID;
    bytes32 baseVoxelTypeId = OakStrippedTable384VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Stripped Table384",
      OakStrippedTable384VoxelID,
      baseVoxelTypeId,
      oakStrippedTable384ChildVoxelTypes,
      oakStrippedTable384ChildVoxelTypes,
      OakStrippedTable384VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C73D384_enterWorld.selector,
        IWorld(world).pretty_C73D384_exitWorld.selector,
        IWorld(world).pretty_C73D384_variantSelector.selector,
        IWorld(world).pretty_C73D384_activate.selector,
        IWorld(world).pretty_C73D384_eventHandler.selector,
        IWorld(world).pretty_C73D384_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakStrippedTable384VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakStrippedTable384VoxelVariantID;
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
