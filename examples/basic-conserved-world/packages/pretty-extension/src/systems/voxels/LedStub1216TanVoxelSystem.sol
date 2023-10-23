// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant LedStub1216TanVoxelID = bytes32(keccak256("led_stub_1216_tan"));
bytes32 constant LedStub1216TanVoxelVariantID = bytes32(keccak256("led_stub_1216_tan"));

contract LedStub1216TanVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory ledStub1216TanVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, LedStub1216TanVoxelVariantID, ledStub1216TanVariant);

    bytes32[] memory ledStub1216TanChildVoxelTypes = new bytes32[](1);
    ledStub1216TanChildVoxelTypes[0] = LedStub1216TanVoxelID;
    bytes32 baseVoxelTypeId = LedStub1216TanVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Led Stub1216 Tan",
      LedStub1216TanVoxelID,
      baseVoxelTypeId,
      ledStub1216TanChildVoxelTypes,
      ledStub1216TanChildVoxelTypes,
      LedStub1216TanVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C64D1216E10_enterWorld.selector,
        IWorld(world).pretty_C64D1216E10_exitWorld.selector,
        IWorld(world).pretty_C64D1216E10_variantSelector.selector,
        IWorld(world).pretty_C64D1216E10_activate.selector,
        IWorld(world).pretty_C64D1216E10_eventHandler.selector,
        IWorld(world).pretty_C64D1216E10_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, LedStub1216TanVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return LedStub1216TanVoxelVariantID;
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
