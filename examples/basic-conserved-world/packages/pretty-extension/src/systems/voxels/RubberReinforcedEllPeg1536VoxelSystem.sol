// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberReinforcedEllPeg1536VoxelID = bytes32(keccak256("rubber_reinforced_ellPeg_1536"));
bytes32 constant RubberReinforcedEllPeg1536VoxelVariantID = bytes32(keccak256("rubber_reinforced_ellPeg_1536"));

contract RubberReinforcedEllPeg1536VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberReinforcedEllPeg1536Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberReinforcedEllPeg1536VoxelVariantID, rubberReinforcedEllPeg1536Variant);

    bytes32[] memory rubberReinforcedEllPeg1536ChildVoxelTypes = new bytes32[](1);
    rubberReinforcedEllPeg1536ChildVoxelTypes[0] = RubberReinforcedEllPeg1536VoxelID;
    bytes32 baseVoxelTypeId = RubberReinforcedEllPeg1536VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Reinforced Ell Peg1536",
      RubberReinforcedEllPeg1536VoxelID,
      baseVoxelTypeId,
      rubberReinforcedEllPeg1536ChildVoxelTypes,
      rubberReinforcedEllPeg1536ChildVoxelTypes,
      RubberReinforcedEllPeg1536VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C74D1536_enterWorld.selector,
        IWorld(world).pretty_C74D1536_exitWorld.selector,
        IWorld(world).pretty_C74D1536_variantSelector.selector,
        IWorld(world).pretty_C74D1536_activate.selector,
        IWorld(world).pretty_C74D1536_eventHandler.selector,
        IWorld(world).pretty_C74D1536_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberReinforcedEllPeg1536VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberReinforcedEllPeg1536VoxelVariantID;
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
