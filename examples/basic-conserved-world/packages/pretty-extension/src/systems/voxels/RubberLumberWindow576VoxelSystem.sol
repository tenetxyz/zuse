// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberLumberWindow576VoxelID = bytes32(keccak256("rubber_lumber_window_576"));
bytes32 constant RubberLumberWindow576VoxelVariantID = bytes32(keccak256("rubber_lumber_window_576"));

contract RubberLumberWindow576VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberLumberWindow576Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberLumberWindow576VoxelVariantID, rubberLumberWindow576Variant);

    bytes32[] memory rubberLumberWindow576ChildVoxelTypes = new bytes32[](1);
    rubberLumberWindow576ChildVoxelTypes[0] = RubberLumberWindow576VoxelID;
    bytes32 baseVoxelTypeId = RubberLumberWindow576VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Lumber Window576",
      RubberLumberWindow576VoxelID,
      baseVoxelTypeId,
      rubberLumberWindow576ChildVoxelTypes,
      rubberLumberWindow576ChildVoxelTypes,
      RubberLumberWindow576VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C34D576_enterWorld.selector,
        IWorld(world).pretty_C34D576_exitWorld.selector,
        IWorld(world).pretty_C34D576_variantSelector.selector,
        IWorld(world).pretty_C34D576_activate.selector,
        IWorld(world).pretty_C34D576_eventHandler.selector,
        IWorld(world).pretty_C34D576_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberLumberWindow576VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberLumberWindow576VoxelVariantID;
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
