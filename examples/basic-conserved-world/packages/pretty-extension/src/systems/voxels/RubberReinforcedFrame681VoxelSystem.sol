// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberReinforcedFrame681VoxelID = bytes32(keccak256("rubber_reinforced_frame_681"));
bytes32 constant RubberReinforcedFrame681VoxelVariantID = bytes32(keccak256("rubber_reinforced_frame_681"));

contract RubberReinforcedFrame681VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberReinforcedFrame681Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberReinforcedFrame681VoxelVariantID, rubberReinforcedFrame681Variant);

    bytes32[] memory rubberReinforcedFrame681ChildVoxelTypes = new bytes32[](1);
    rubberReinforcedFrame681ChildVoxelTypes[0] = RubberReinforcedFrame681VoxelID;
    bytes32 baseVoxelTypeId = RubberReinforcedFrame681VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Reinforced Frame681",
      RubberReinforcedFrame681VoxelID,
      baseVoxelTypeId,
      rubberReinforcedFrame681ChildVoxelTypes,
      rubberReinforcedFrame681ChildVoxelTypes,
      RubberReinforcedFrame681VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C74681_enterWorld.selector,
        IWorld(world).pretty_C74681_exitWorld.selector,
        IWorld(world).pretty_C74681_variantSelector.selector,
        IWorld(world).pretty_C74681_activate.selector,
        IWorld(world).pretty_C74681_eventHandler.selector,
        IWorld(world).pretty_C74681_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberReinforcedFrame681VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberReinforcedFrame681VoxelVariantID;
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
