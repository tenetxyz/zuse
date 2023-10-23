// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant LedStub1218PinkVoxelID = bytes32(keccak256("led_stub_1218_pink"));
bytes32 constant LedStub1218PinkVoxelVariantID = bytes32(keccak256("led_stub_1218_pink"));

contract LedStub1218PinkVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory ledStub1218PinkVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, LedStub1218PinkVoxelVariantID, ledStub1218PinkVariant);

    bytes32[] memory ledStub1218PinkChildVoxelTypes = new bytes32[](1);
    ledStub1218PinkChildVoxelTypes[0] = LedStub1218PinkVoxelID;
    bytes32 baseVoxelTypeId = LedStub1218PinkVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Led Stub1218 Pink",
      LedStub1218PinkVoxelID,
      baseVoxelTypeId,
      ledStub1218PinkChildVoxelTypes,
      ledStub1218PinkChildVoxelTypes,
      LedStub1218PinkVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C64D1218E7_enterWorld.selector,
        IWorld(world).pretty_C64D1218E7_exitWorld.selector,
        IWorld(world).pretty_C64D1218E7_variantSelector.selector,
        IWorld(world).pretty_C64D1218E7_activate.selector,
        IWorld(world).pretty_C64D1218E7_eventHandler.selector,
        IWorld(world).pretty_C64D1218E7_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, LedStub1218PinkVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return LedStub1218PinkVoxelVariantID;
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
