// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BirchLumberStep235VoxelID = bytes32(keccak256("birch_lumber_step_235"));
bytes32 constant BirchLumberStep235VoxelVariantID = bytes32(keccak256("birch_lumber_step_235"));

contract BirchLumberStep235VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory birchLumberStep235Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BirchLumberStep235VoxelVariantID, birchLumberStep235Variant);

    bytes32[] memory birchLumberStep235ChildVoxelTypes = new bytes32[](1);
    birchLumberStep235ChildVoxelTypes[0] = BirchLumberStep235VoxelID;
    bytes32 baseVoxelTypeId = BirchLumberStep235VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Birch Lumber Step235",
      BirchLumberStep235VoxelID,
      baseVoxelTypeId,
      birchLumberStep235ChildVoxelTypes,
      birchLumberStep235ChildVoxelTypes,
      BirchLumberStep235VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C16D235_enterWorld.selector,
        IWorld(world).pretty_C16D235_exitWorld.selector,
        IWorld(world).pretty_C16D235_variantSelector.selector,
        IWorld(world).pretty_C16D235_activate.selector,
        IWorld(world).pretty_C16D235_eventHandler.selector,
        IWorld(world).pretty_C16D235_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BirchLumberStep235VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BirchLumberStep235VoxelVariantID;
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
