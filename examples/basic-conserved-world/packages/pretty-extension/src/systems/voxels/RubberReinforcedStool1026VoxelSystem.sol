// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberReinforcedStool1026VoxelID = bytes32(keccak256("rubber_reinforced_stool_1026"));
bytes32 constant RubberReinforcedStool1026VoxelVariantID = bytes32(keccak256("rubber_reinforced_stool_1026"));

contract RubberReinforcedStool1026VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberReinforcedStool1026Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberReinforcedStool1026VoxelVariantID, rubberReinforcedStool1026Variant);

    bytes32[] memory rubberReinforcedStool1026ChildVoxelTypes = new bytes32[](1);
    rubberReinforcedStool1026ChildVoxelTypes[0] = RubberReinforcedStool1026VoxelID;
    bytes32 baseVoxelTypeId = RubberReinforcedStool1026VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Reinforced Stool1026",
      RubberReinforcedStool1026VoxelID,
      baseVoxelTypeId,
      rubberReinforcedStool1026ChildVoxelTypes,
      rubberReinforcedStool1026ChildVoxelTypes,
      RubberReinforcedStool1026VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C741026_enterWorld.selector,
        IWorld(world).pretty_C741026_exitWorld.selector,
        IWorld(world).pretty_C741026_variantSelector.selector,
        IWorld(world).pretty_C741026_activate.selector,
        IWorld(world).pretty_C741026_eventHandler.selector,
        IWorld(world).pretty_C741026_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, RubberReinforcedStool1026VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberReinforcedStool1026VoxelVariantID;
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
