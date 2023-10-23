// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant LedSlice709BrightyellowVoxelID = bytes32(keccak256("led_slice_709_brightyellow"));
bytes32 constant LedSlice709BrightyellowVoxelVariantID = bytes32(keccak256("led_slice_709_brightyellow"));

contract LedSlice709BrightyellowVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory ledSlice709BrightyellowVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, LedSlice709BrightyellowVoxelVariantID, ledSlice709BrightyellowVariant);

    bytes32[] memory ledSlice709BrightyellowChildVoxelTypes = new bytes32[](1);
    ledSlice709BrightyellowChildVoxelTypes[0] = LedSlice709BrightyellowVoxelID;
    bytes32 baseVoxelTypeId = LedSlice709BrightyellowVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Led Slice709 Brightyellow",
      LedSlice709BrightyellowVoxelID,
      baseVoxelTypeId,
      ledSlice709BrightyellowChildVoxelTypes,
      ledSlice709BrightyellowChildVoxelTypes,
      LedSlice709BrightyellowVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C64D709E19_enterWorld.selector,
        IWorld(world).pretty_C64D709E19_exitWorld.selector,
        IWorld(world).pretty_C64D709E19_variantSelector.selector,
        IWorld(world).pretty_C64D709E19_activate.selector,
        IWorld(world).pretty_C64D709E19_eventHandler.selector,
        IWorld(world).pretty_C64D709E19_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, LedSlice709BrightyellowVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return LedSlice709BrightyellowVoxelVariantID;
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
