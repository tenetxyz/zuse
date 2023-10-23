// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BirchLumberStep238VoxelID = bytes32(keccak256("birch_lumber_step_238"));
bytes32 constant BirchLumberStep238VoxelVariantID = bytes32(keccak256("birch_lumber_step_238"));

contract BirchLumberStep238VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory birchLumberStep238Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BirchLumberStep238VoxelVariantID, birchLumberStep238Variant);

    bytes32[] memory birchLumberStep238ChildVoxelTypes = new bytes32[](1);
    birchLumberStep238ChildVoxelTypes[0] = BirchLumberStep238VoxelID;
    bytes32 baseVoxelTypeId = BirchLumberStep238VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Birch Lumber Step238",
      BirchLumberStep238VoxelID,
      baseVoxelTypeId,
      birchLumberStep238ChildVoxelTypes,
      birchLumberStep238ChildVoxelTypes,
      BirchLumberStep238VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C16D238_enterWorld.selector,
        IWorld(world).pretty_C16D238_exitWorld.selector,
        IWorld(world).pretty_C16D238_variantSelector.selector,
        IWorld(world).pretty_C16D238_activate.selector,
        IWorld(world).pretty_C16D238_eventHandler.selector,
        IWorld(world).pretty_C16D238_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BirchLumberStep238VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BirchLumberStep238VoxelVariantID;
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
