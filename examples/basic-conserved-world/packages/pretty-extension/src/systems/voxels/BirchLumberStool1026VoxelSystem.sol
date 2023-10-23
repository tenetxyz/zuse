// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BirchLumberStool1026VoxelID = bytes32(keccak256("birch_lumber_stool_1026"));
bytes32 constant BirchLumberStool1026VoxelVariantID = bytes32(keccak256("birch_lumber_stool_1026"));

contract BirchLumberStool1026VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory birchLumberStool1026Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BirchLumberStool1026VoxelVariantID, birchLumberStool1026Variant);

    bytes32[] memory birchLumberStool1026ChildVoxelTypes = new bytes32[](1);
    birchLumberStool1026ChildVoxelTypes[0] = BirchLumberStool1026VoxelID;
    bytes32 baseVoxelTypeId = BirchLumberStool1026VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Birch Lumber Stool1026",
      BirchLumberStool1026VoxelID,
      baseVoxelTypeId,
      birchLumberStool1026ChildVoxelTypes,
      birchLumberStool1026ChildVoxelTypes,
      BirchLumberStool1026VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C16D1026_enterWorld.selector,
        IWorld(world).pretty_C16D1026_exitWorld.selector,
        IWorld(world).pretty_C16D1026_variantSelector.selector,
        IWorld(world).pretty_C16D1026_activate.selector,
        IWorld(world).pretty_C16D1026_eventHandler.selector,
        IWorld(world).pretty_C16D1026_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BirchLumberStool1026VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BirchLumberStool1026VoxelVariantID;
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
