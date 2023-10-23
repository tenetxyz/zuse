// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberStrippedWindow620VoxelID = bytes32(keccak256("rubber_stripped_window_620"));
bytes32 constant RubberStrippedWindow620VoxelVariantID = bytes32(keccak256("rubber_stripped_window_620"));

contract RubberStrippedWindow620VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberStrippedWindow620Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberStrippedWindow620VoxelVariantID, rubberStrippedWindow620Variant);

    bytes32[] memory rubberStrippedWindow620ChildVoxelTypes = new bytes32[](1);
    rubberStrippedWindow620ChildVoxelTypes[0] = RubberStrippedWindow620VoxelID;
    bytes32 baseVoxelTypeId = RubberStrippedWindow620VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Stripped Window620",
      RubberStrippedWindow620VoxelID,
      baseVoxelTypeId,
      rubberStrippedWindow620ChildVoxelTypes,
      rubberStrippedWindow620ChildVoxelTypes,
      RubberStrippedWindow620VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C75D620_enterWorld.selector,
        IWorld(world).pretty_C75D620_exitWorld.selector,
        IWorld(world).pretty_C75D620_variantSelector.selector,
        IWorld(world).pretty_C75D620_activate.selector,
        IWorld(world).pretty_C75D620_eventHandler.selector,
        IWorld(world).pretty_C75D620_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberStrippedWindow620VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberStrippedWindow620VoxelVariantID;
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
