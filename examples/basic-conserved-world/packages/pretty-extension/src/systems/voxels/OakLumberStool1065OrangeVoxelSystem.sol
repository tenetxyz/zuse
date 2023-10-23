// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberStool1065OrangeVoxelID = bytes32(keccak256("oak_lumber_stool_1065_orange"));
bytes32 constant OakLumberStool1065OrangeVoxelVariantID = bytes32(keccak256("oak_lumber_stool_1065_orange"));

contract OakLumberStool1065OrangeVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberStool1065OrangeVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberStool1065OrangeVoxelVariantID, oakLumberStool1065OrangeVariant);

    bytes32[] memory oakLumberStool1065OrangeChildVoxelTypes = new bytes32[](1);
    oakLumberStool1065OrangeChildVoxelTypes[0] = OakLumberStool1065OrangeVoxelID;
    bytes32 baseVoxelTypeId = OakLumberStool1065OrangeVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Stool1065 Orange",
      OakLumberStool1065OrangeVoxelID,
      baseVoxelTypeId,
      oakLumberStool1065OrangeChildVoxelTypes,
      oakLumberStool1065OrangeChildVoxelTypes,
      OakLumberStool1065OrangeVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D1065E4_enterWorld.selector,
        IWorld(world).pretty_C31D1065E4_exitWorld.selector,
        IWorld(world).pretty_C31D1065E4_variantSelector.selector,
        IWorld(world).pretty_C31D1065E4_activate.selector,
        IWorld(world).pretty_C31D1065E4_eventHandler.selector,
        IWorld(world).pretty_C31D1065E4_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberStool1065OrangeVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberStool1065OrangeVoxelVariantID;
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
