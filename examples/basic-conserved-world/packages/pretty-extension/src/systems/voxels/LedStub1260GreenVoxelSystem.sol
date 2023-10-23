// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant LedStub1260GreenVoxelID = bytes32(keccak256("led_stub_1260_green"));
bytes32 constant LedStub1260GreenVoxelVariantID = bytes32(keccak256("led_stub_1260_green"));

contract LedStub1260GreenVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory ledStub1260GreenVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, LedStub1260GreenVoxelVariantID, ledStub1260GreenVariant);

    bytes32[] memory ledStub1260GreenChildVoxelTypes = new bytes32[](1);
    ledStub1260GreenChildVoxelTypes[0] = LedStub1260GreenVoxelID;
    bytes32 baseVoxelTypeId = LedStub1260GreenVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Led Stub1260 Green",
      LedStub1260GreenVoxelID,
      baseVoxelTypeId,
      ledStub1260GreenChildVoxelTypes,
      ledStub1260GreenChildVoxelTypes,
      LedStub1260GreenVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C64D1260E3_enterWorld.selector,
        IWorld(world).pretty_C64D1260E3_exitWorld.selector,
        IWorld(world).pretty_C64D1260E3_variantSelector.selector,
        IWorld(world).pretty_C64D1260E3_activate.selector,
        IWorld(world).pretty_C64D1260E3_eventHandler.selector,
        IWorld(world).pretty_C64D1260E3_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, LedStub1260GreenVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return LedStub1260GreenVoxelVariantID;
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
