// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberStep236WhiteVoxelID = bytes32(keccak256("oak_lumber_step_236_white"));
bytes32 constant OakLumberStep236WhiteVoxelVariantID = bytes32(keccak256("oak_lumber_step_236_white"));

contract OakLumberStep236WhiteVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberStep236WhiteVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberStep236WhiteVoxelVariantID, oakLumberStep236WhiteVariant);

    bytes32[] memory oakLumberStep236WhiteChildVoxelTypes = new bytes32[](1);
    oakLumberStep236WhiteChildVoxelTypes[0] = OakLumberStep236WhiteVoxelID;
    bytes32 baseVoxelTypeId = OakLumberStep236WhiteVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Step236 White",
      OakLumberStep236WhiteVoxelID,
      baseVoxelTypeId,
      oakLumberStep236WhiteChildVoxelTypes,
      oakLumberStep236WhiteChildVoxelTypes,
      OakLumberStep236WhiteVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C312365_enterWorld.selector,
        IWorld(world).pretty_C312365_exitWorld.selector,
        IWorld(world).pretty_C312365_variantSelector.selector,
        IWorld(world).pretty_C312365_activate.selector,
        IWorld(world).pretty_C312365_eventHandler.selector,
        IWorld(world).pretty_C312365_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberStep236WhiteVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberStep236WhiteVoxelVariantID;
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
