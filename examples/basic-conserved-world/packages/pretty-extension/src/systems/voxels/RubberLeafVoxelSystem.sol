// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberLeafVoxelID = bytes32(keccak256("rubber_leaf"));
bytes32 constant RubberLeafVoxelVariantID = bytes32(keccak256("rubber_leaf"));

contract RubberLeafVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberLeafVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberLeafVoxelVariantID, rubberLeafVariant);

    bytes32[] memory rubberLeafChildVoxelTypes = new bytes32[](1);
    rubberLeafChildVoxelTypes[0] = RubberLeafVoxelID;
    bytes32 baseVoxelTypeId = RubberLeafVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Leaf",
      RubberLeafVoxelID,
      baseVoxelTypeId,
      rubberLeafChildVoxelTypes,
      rubberLeafChildVoxelTypes,
      RubberLeafVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C16777219_enterWorld.selector,
        IWorld(world).pretty_C16777219_exitWorld.selector,
        IWorld(world).pretty_C16777219_variantSelector.selector,
        IWorld(world).pretty_C16777219_activate.selector,
        IWorld(world).pretty_C16777219_eventHandler.selector,
        IWorld(world).pretty_C16777219_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberLeafVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberLeafVoxelVariantID;
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
