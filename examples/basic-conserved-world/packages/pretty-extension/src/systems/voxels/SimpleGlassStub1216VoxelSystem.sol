// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant SimpleGlassStub1216VoxelID = bytes32(keccak256("simple_glass_stub_1216"));
bytes32 constant SimpleGlassStub1216VoxelVariantID = bytes32(keccak256("simple_glass_stub_1216"));

contract SimpleGlassStub1216VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory simpleGlassStub1216Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, SimpleGlassStub1216VoxelVariantID, simpleGlassStub1216Variant);

    bytes32[] memory simpleGlassStub1216ChildVoxelTypes = new bytes32[](1);
    simpleGlassStub1216ChildVoxelTypes[0] = SimpleGlassStub1216VoxelID;
    bytes32 baseVoxelTypeId = SimpleGlassStub1216VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Simple Glass Stub1216",
      SimpleGlassStub1216VoxelID,
      baseVoxelTypeId,
      simpleGlassStub1216ChildVoxelTypes,
      simpleGlassStub1216ChildVoxelTypes,
      SimpleGlassStub1216VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C33554433D1216_enterWorld.selector,
        IWorld(world).pretty_C33554433D1216_exitWorld.selector,
        IWorld(world).pretty_C33554433D1216_variantSelector.selector,
        IWorld(world).pretty_C33554433D1216_activate.selector,
        IWorld(world).pretty_C33554433D1216_eventHandler.selector,
        IWorld(world).pretty_C33554433D1216_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, SimpleGlassStub1216VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return SimpleGlassStub1216VoxelVariantID;
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
