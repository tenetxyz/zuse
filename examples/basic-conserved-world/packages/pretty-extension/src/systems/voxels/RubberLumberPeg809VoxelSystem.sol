// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberLumberPeg809VoxelID = bytes32(keccak256("rubber_lumber_peg_809"));
bytes32 constant RubberLumberPeg809VoxelVariantID = bytes32(keccak256("rubber_lumber_peg_809"));

contract RubberLumberPeg809VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberLumberPeg809Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberLumberPeg809VoxelVariantID, rubberLumberPeg809Variant);

    bytes32[] memory rubberLumberPeg809ChildVoxelTypes = new bytes32[](1);
    rubberLumberPeg809ChildVoxelTypes[0] = RubberLumberPeg809VoxelID;
    bytes32 baseVoxelTypeId = RubberLumberPeg809VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Lumber Peg809",
      RubberLumberPeg809VoxelID,
      baseVoxelTypeId,
      rubberLumberPeg809ChildVoxelTypes,
      rubberLumberPeg809ChildVoxelTypes,
      RubberLumberPeg809VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C34D809_enterWorld.selector,
        IWorld(world).pretty_C34D809_exitWorld.selector,
        IWorld(world).pretty_C34D809_variantSelector.selector,
        IWorld(world).pretty_C34D809_activate.selector,
        IWorld(world).pretty_C34D809_eventHandler.selector,
        IWorld(world).pretty_C34D809_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberLumberPeg809VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberLumberPeg809VoxelVariantID;
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
