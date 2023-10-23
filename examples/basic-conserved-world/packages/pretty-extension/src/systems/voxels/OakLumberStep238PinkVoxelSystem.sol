// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberStep238PinkVoxelID = bytes32(keccak256("oak_lumber_step_238_pink"));
bytes32 constant OakLumberStep238PinkVoxelVariantID = bytes32(keccak256("oak_lumber_step_238_pink"));

contract OakLumberStep238PinkVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberStep238PinkVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberStep238PinkVoxelVariantID, oakLumberStep238PinkVariant);

    bytes32[] memory oakLumberStep238PinkChildVoxelTypes = new bytes32[](1);
    oakLumberStep238PinkChildVoxelTypes[0] = OakLumberStep238PinkVoxelID;
    bytes32 baseVoxelTypeId = OakLumberStep238PinkVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Step238 Pink",
      OakLumberStep238PinkVoxelID,
      baseVoxelTypeId,
      oakLumberStep238PinkChildVoxelTypes,
      oakLumberStep238PinkChildVoxelTypes,
      OakLumberStep238PinkVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D238E7_enterWorld.selector,
        IWorld(world).pretty_C31D238E7_exitWorld.selector,
        IWorld(world).pretty_C31D238E7_variantSelector.selector,
        IWorld(world).pretty_C31D238E7_activate.selector,
        IWorld(world).pretty_C31D238E7_eventHandler.selector,
        IWorld(world).pretty_C31D238E7_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberStep238PinkVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberStep238PinkVoxelVariantID;
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
