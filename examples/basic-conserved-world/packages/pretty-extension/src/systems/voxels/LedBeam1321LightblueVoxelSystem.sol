// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant LedBeam1321LightblueVoxelID = bytes32(keccak256("led_beam_1321_lightblue"));
bytes32 constant LedBeam1321LightblueVoxelVariantID = bytes32(keccak256("led_beam_1321_lightblue"));

contract LedBeam1321LightblueVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory ledBeam1321LightblueVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, LedBeam1321LightblueVoxelVariantID, ledBeam1321LightblueVariant);

    bytes32[] memory ledBeam1321LightblueChildVoxelTypes = new bytes32[](1);
    ledBeam1321LightblueChildVoxelTypes[0] = LedBeam1321LightblueVoxelID;
    bytes32 baseVoxelTypeId = LedBeam1321LightblueVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Led Beam1321 Lightblue",
      LedBeam1321LightblueVoxelID,
      baseVoxelTypeId,
      ledBeam1321LightblueChildVoxelTypes,
      ledBeam1321LightblueChildVoxelTypes,
      LedBeam1321LightblueVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C64D1321E22_enterWorld.selector,
        IWorld(world).pretty_C64D1321E22_exitWorld.selector,
        IWorld(world).pretty_C64D1321E22_variantSelector.selector,
        IWorld(world).pretty_C64D1321E22_activate.selector,
        IWorld(world).pretty_C64D1321E22_eventHandler.selector,
        IWorld(world).pretty_C64D1321E22_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, LedBeam1321LightblueVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return LedBeam1321LightblueVoxelVariantID;
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
