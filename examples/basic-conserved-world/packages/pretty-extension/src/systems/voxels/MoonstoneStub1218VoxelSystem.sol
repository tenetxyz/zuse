// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant MoonstoneStub1218VoxelID = bytes32(keccak256("moonstone_stub_1218"));
bytes32 constant MoonstoneStub1218VoxelVariantID = bytes32(keccak256("moonstone_stub_1218"));

contract MoonstoneStub1218VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory moonstoneStub1218Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, MoonstoneStub1218VoxelVariantID, moonstoneStub1218Variant);

    bytes32[] memory moonstoneStub1218ChildVoxelTypes = new bytes32[](1);
    moonstoneStub1218ChildVoxelTypes[0] = MoonstoneStub1218VoxelID;
    bytes32 baseVoxelTypeId = MoonstoneStub1218VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Moonstone Stub1218",
      MoonstoneStub1218VoxelID,
      baseVoxelTypeId,
      moonstoneStub1218ChildVoxelTypes,
      moonstoneStub1218ChildVoxelTypes,
      MoonstoneStub1218VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C67D1218_enterWorld.selector,
        IWorld(world).pretty_C67D1218_exitWorld.selector,
        IWorld(world).pretty_C67D1218_variantSelector.selector,
        IWorld(world).pretty_C67D1218_activate.selector,
        IWorld(world).pretty_C67D1218_eventHandler.selector,
        IWorld(world).pretty_C67D1218_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, MoonstoneStub1218VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return MoonstoneStub1218VoxelVariantID;
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
