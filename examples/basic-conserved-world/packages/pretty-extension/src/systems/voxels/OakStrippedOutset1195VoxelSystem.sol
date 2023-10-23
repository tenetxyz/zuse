// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakStrippedOutset1195VoxelID = bytes32(keccak256("oak_stripped_outset_1195"));
bytes32 constant OakStrippedOutset1195VoxelVariantID = bytes32(keccak256("oak_stripped_outset_1195"));

contract OakStrippedOutset1195VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakStrippedOutset1195Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakStrippedOutset1195VoxelVariantID, oakStrippedOutset1195Variant);

    bytes32[] memory oakStrippedOutset1195ChildVoxelTypes = new bytes32[](1);
    oakStrippedOutset1195ChildVoxelTypes[0] = OakStrippedOutset1195VoxelID;
    bytes32 baseVoxelTypeId = OakStrippedOutset1195VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Stripped Outset1195",
      OakStrippedOutset1195VoxelID,
      baseVoxelTypeId,
      oakStrippedOutset1195ChildVoxelTypes,
      oakStrippedOutset1195ChildVoxelTypes,
      OakStrippedOutset1195VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C73D1195_enterWorld.selector,
        IWorld(world).pretty_C73D1195_exitWorld.selector,
        IWorld(world).pretty_C73D1195_variantSelector.selector,
        IWorld(world).pretty_C73D1195_activate.selector,
        IWorld(world).pretty_C73D1195_eventHandler.selector,
        IWorld(world).pretty_C73D1195_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakStrippedOutset1195VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakStrippedOutset1195VoxelVariantID;
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
