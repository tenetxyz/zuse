// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberLumberPeg773VoxelID = bytes32(keccak256("rubber_lumber_peg_773"));
bytes32 constant RubberLumberPeg773VoxelVariantID = bytes32(keccak256("rubber_lumber_peg_773"));

contract RubberLumberPeg773VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberLumberPeg773Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberLumberPeg773VoxelVariantID, rubberLumberPeg773Variant);

    bytes32[] memory rubberLumberPeg773ChildVoxelTypes = new bytes32[](1);
    rubberLumberPeg773ChildVoxelTypes[0] = RubberLumberPeg773VoxelID;
    bytes32 baseVoxelTypeId = RubberLumberPeg773VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Lumber Peg773",
      RubberLumberPeg773VoxelID,
      baseVoxelTypeId,
      rubberLumberPeg773ChildVoxelTypes,
      rubberLumberPeg773ChildVoxelTypes,
      RubberLumberPeg773VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C34D773_enterWorld.selector,
        IWorld(world).pretty_C34D773_exitWorld.selector,
        IWorld(world).pretty_C34D773_variantSelector.selector,
        IWorld(world).pretty_C34D773_activate.selector,
        IWorld(world).pretty_C34D773_eventHandler.selector,
        IWorld(world).pretty_C34D773_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberLumberPeg773VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberLumberPeg773VoxelVariantID;
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
