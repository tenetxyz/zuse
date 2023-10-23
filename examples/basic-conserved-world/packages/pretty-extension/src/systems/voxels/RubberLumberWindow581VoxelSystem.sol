// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberLumberWindow581VoxelID = bytes32(keccak256("rubber_lumber_window_581"));
bytes32 constant RubberLumberWindow581VoxelVariantID = bytes32(keccak256("rubber_lumber_window_581"));

contract RubberLumberWindow581VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberLumberWindow581Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberLumberWindow581VoxelVariantID, rubberLumberWindow581Variant);

    bytes32[] memory rubberLumberWindow581ChildVoxelTypes = new bytes32[](1);
    rubberLumberWindow581ChildVoxelTypes[0] = RubberLumberWindow581VoxelID;
    bytes32 baseVoxelTypeId = RubberLumberWindow581VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Lumber Window581",
      RubberLumberWindow581VoxelID,
      baseVoxelTypeId,
      rubberLumberWindow581ChildVoxelTypes,
      rubberLumberWindow581ChildVoxelTypes,
      RubberLumberWindow581VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C34D581_enterWorld.selector,
        IWorld(world).pretty_C34D581_exitWorld.selector,
        IWorld(world).pretty_C34D581_variantSelector.selector,
        IWorld(world).pretty_C34D581_activate.selector,
        IWorld(world).pretty_C34D581_eventHandler.selector,
        IWorld(world).pretty_C34D581_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberLumberWindow581VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberLumberWindow581VoxelVariantID;
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
