// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant LedStub1223VoxelID = bytes32(keccak256("led_stub_1223"));
bytes32 constant LedStub1223VoxelVariantID = bytes32(keccak256("led_stub_1223"));

contract LedStub1223VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory ledStub1223Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, LedStub1223VoxelVariantID, ledStub1223Variant);

    bytes32[] memory ledStub1223ChildVoxelTypes = new bytes32[](1);
    ledStub1223ChildVoxelTypes[0] = LedStub1223VoxelID;
    bytes32 baseVoxelTypeId = LedStub1223VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Led Stub1223",
      LedStub1223VoxelID,
      baseVoxelTypeId,
      ledStub1223ChildVoxelTypes,
      ledStub1223ChildVoxelTypes,
      LedStub1223VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C64D1223_enterWorld.selector,
        IWorld(world).pretty_C64D1223_exitWorld.selector,
        IWorld(world).pretty_C64D1223_variantSelector.selector,
        IWorld(world).pretty_C64D1223_activate.selector,
        IWorld(world).pretty_C64D1223_eventHandler.selector,
        IWorld(world).pretty_C64D1223_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, LedStub1223VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return LedStub1223VoxelVariantID;
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
