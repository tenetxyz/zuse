// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant LedBeam1285BlueVoxelID = bytes32(keccak256("led_beam_1285_blue"));
bytes32 constant LedBeam1285BlueVoxelVariantID = bytes32(keccak256("led_beam_1285_blue"));

contract LedBeam1285BlueVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory ledBeam1285BlueVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, LedBeam1285BlueVoxelVariantID, ledBeam1285BlueVariant);

    bytes32[] memory ledBeam1285BlueChildVoxelTypes = new bytes32[](1);
    ledBeam1285BlueChildVoxelTypes[0] = LedBeam1285BlueVoxelID;
    bytes32 baseVoxelTypeId = LedBeam1285BlueVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Led Beam1285 Blue",
      LedBeam1285BlueVoxelID,
      baseVoxelTypeId,
      ledBeam1285BlueChildVoxelTypes,
      ledBeam1285BlueChildVoxelTypes,
      LedBeam1285BlueVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C64D1285E1_enterWorld.selector,
        IWorld(world).pretty_C64D1285E1_exitWorld.selector,
        IWorld(world).pretty_C64D1285E1_variantSelector.selector,
        IWorld(world).pretty_C64D1285E1_activate.selector,
        IWorld(world).pretty_C64D1285E1_eventHandler.selector,
        IWorld(world).pretty_C64D1285E1_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, LedBeam1285BlueVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return LedBeam1285BlueVoxelVariantID;
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
