// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberStep236VoxelID = bytes32(keccak256("oak_lumber_step_236"));
bytes32 constant OakLumberStep236VoxelVariantID = bytes32(keccak256("oak_lumber_step_236"));

contract OakLumberStep236VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberStep236Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberStep236VoxelVariantID, oakLumberStep236Variant);

    bytes32[] memory oakLumberStep236ChildVoxelTypes = new bytes32[](1);
    oakLumberStep236ChildVoxelTypes[0] = OakLumberStep236VoxelID;
    bytes32 baseVoxelTypeId = OakLumberStep236VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Step236",
      OakLumberStep236VoxelID,
      baseVoxelTypeId,
      oakLumberStep236ChildVoxelTypes,
      oakLumberStep236ChildVoxelTypes,
      OakLumberStep236VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D236_enterWorld.selector,
        IWorld(world).pretty_C31D236_exitWorld.selector,
        IWorld(world).pretty_C31D236_variantSelector.selector,
        IWorld(world).pretty_C31D236_activate.selector,
        IWorld(world).pretty_C31D236_eventHandler.selector,
        IWorld(world).pretty_C31D236_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberStep236VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberStep236VoxelVariantID;
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
