// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakStrippedStool1070VoxelID = bytes32(keccak256("oak_stripped_stool_1070"));
bytes32 constant OakStrippedStool1070VoxelVariantID = bytes32(keccak256("oak_stripped_stool_1070"));

contract OakStrippedStool1070VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakStrippedStool1070Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakStrippedStool1070VoxelVariantID, oakStrippedStool1070Variant);

    bytes32[] memory oakStrippedStool1070ChildVoxelTypes = new bytes32[](1);
    oakStrippedStool1070ChildVoxelTypes[0] = OakStrippedStool1070VoxelID;
    bytes32 baseVoxelTypeId = OakStrippedStool1070VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Stripped Stool1070",
      OakStrippedStool1070VoxelID,
      baseVoxelTypeId,
      oakStrippedStool1070ChildVoxelTypes,
      oakStrippedStool1070ChildVoxelTypes,
      OakStrippedStool1070VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C73D1070_enterWorld.selector,
        IWorld(world).pretty_C73D1070_exitWorld.selector,
        IWorld(world).pretty_C73D1070_variantSelector.selector,
        IWorld(world).pretty_C73D1070_activate.selector,
        IWorld(world).pretty_C73D1070_eventHandler.selector,
        IWorld(world).pretty_C73D1070_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakStrippedStool1070VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakStrippedStool1070VoxelVariantID;
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
