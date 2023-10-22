// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant SwitchGrassVoxelID = bytes32(keccak256("switch_grass"));
bytes32 constant SwitchGrassVoxelVariantID = bytes32(keccak256("switch_grass"));

contract SwitchGrassVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory switchGrassVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, SwitchGrassVoxelVariantID, switchGrassVariant);

    bytes32[] memory switchGrassChildVoxelTypes = new bytes32[](1);
    switchGrassChildVoxelTypes[0] = SwitchGrassVoxelID;
    bytes32 baseVoxelTypeId = SwitchGrassVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Switch Grass",
      SwitchGrassVoxelID,
      baseVoxelTypeId,
      switchGrassChildVoxelTypes,
      switchGrassChildVoxelTypes,
      SwitchGrassVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C16777220_enterWorld.selector,
        IWorld(world).pretty_C16777220_exitWorld.selector,
        IWorld(world).pretty_C16777220_variantSelector.selector,
        IWorld(world).pretty_C16777220_activate.selector,
        IWorld(world).pretty_C16777220_eventHandler.selector,
        IWorld(world).pretty_C16777220_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, SwitchGrassVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return SwitchGrassVoxelVariantID;
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
