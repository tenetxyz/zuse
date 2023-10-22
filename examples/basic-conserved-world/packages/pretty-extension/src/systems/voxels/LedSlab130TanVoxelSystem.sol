// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant LedSlab130TanVoxelID = bytes32(keccak256("led_slab_130_tan"));
bytes32 constant LedSlab130TanVoxelVariantID = bytes32(keccak256("led_slab_130_tan"));

contract LedSlab130TanVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory ledSlab130TanVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, LedSlab130TanVoxelVariantID, ledSlab130TanVariant);

    bytes32[] memory ledSlab130TanChildVoxelTypes = new bytes32[](1);
    ledSlab130TanChildVoxelTypes[0] = LedSlab130TanVoxelID;
    bytes32 baseVoxelTypeId = LedSlab130TanVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Led Slab130 Tan",
      LedSlab130TanVoxelID,
      baseVoxelTypeId,
      ledSlab130TanChildVoxelTypes,
      ledSlab130TanChildVoxelTypes,
      LedSlab130TanVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C6413010_enterWorld.selector,
        IWorld(world).pretty_C6413010_exitWorld.selector,
        IWorld(world).pretty_C6413010_variantSelector.selector,
        IWorld(world).pretty_C6413010_activate.selector,
        IWorld(world).pretty_C6413010_eventHandler.selector,
        IWorld(world).pretty_C6413010_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, LedSlab130TanVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return LedSlab130TanVoxelVariantID;
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
