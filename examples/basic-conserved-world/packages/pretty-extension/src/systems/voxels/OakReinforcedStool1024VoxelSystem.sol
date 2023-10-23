// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakReinforcedStool1024VoxelID = bytes32(keccak256("oak_reinforced_stool_1024"));
bytes32 constant OakReinforcedStool1024VoxelVariantID = bytes32(keccak256("oak_reinforced_stool_1024"));

contract OakReinforcedStool1024VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakReinforcedStool1024Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakReinforcedStool1024VoxelVariantID, oakReinforcedStool1024Variant);

    bytes32[] memory oakReinforcedStool1024ChildVoxelTypes = new bytes32[](1);
    oakReinforcedStool1024ChildVoxelTypes[0] = OakReinforcedStool1024VoxelID;
    bytes32 baseVoxelTypeId = OakReinforcedStool1024VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Reinforced Stool1024",
      OakReinforcedStool1024VoxelID,
      baseVoxelTypeId,
      oakReinforcedStool1024ChildVoxelTypes,
      oakReinforcedStool1024ChildVoxelTypes,
      OakReinforcedStool1024VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C72D1024_enterWorld.selector,
        IWorld(world).pretty_C72D1024_exitWorld.selector,
        IWorld(world).pretty_C72D1024_variantSelector.selector,
        IWorld(world).pretty_C72D1024_activate.selector,
        IWorld(world).pretty_C72D1024_eventHandler.selector,
        IWorld(world).pretty_C72D1024_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakReinforcedStool1024VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakReinforcedStool1024VoxelVariantID;
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
