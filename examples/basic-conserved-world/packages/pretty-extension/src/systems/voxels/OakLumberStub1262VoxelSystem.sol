// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberStub1262VoxelID = bytes32(keccak256("oak_lumber_stub_1262"));
bytes32 constant OakLumberStub1262VoxelVariantID = bytes32(keccak256("oak_lumber_stub_1262"));

contract OakLumberStub1262VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberStub1262Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberStub1262VoxelVariantID, oakLumberStub1262Variant);

    bytes32[] memory oakLumberStub1262ChildVoxelTypes = new bytes32[](1);
    oakLumberStub1262ChildVoxelTypes[0] = OakLumberStub1262VoxelID;
    bytes32 baseVoxelTypeId = OakLumberStub1262VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Stub1262",
      OakLumberStub1262VoxelID,
      baseVoxelTypeId,
      oakLumberStub1262ChildVoxelTypes,
      oakLumberStub1262ChildVoxelTypes,
      OakLumberStub1262VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D1262_enterWorld.selector,
        IWorld(world).pretty_C31D1262_exitWorld.selector,
        IWorld(world).pretty_C31D1262_variantSelector.selector,
        IWorld(world).pretty_C31D1262_activate.selector,
        IWorld(world).pretty_C31D1262_eventHandler.selector,
        IWorld(world).pretty_C31D1262_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberStub1262VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberStub1262VoxelVariantID;
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
