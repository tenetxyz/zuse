// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberStep199RedVoxelID = bytes32(keccak256("oak_lumber_step_199_red"));
bytes32 constant OakLumberStep199RedVoxelVariantID = bytes32(keccak256("oak_lumber_step_199_red"));

contract OakLumberStep199RedVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberStep199RedVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberStep199RedVoxelVariantID, oakLumberStep199RedVariant);

    bytes32[] memory oakLumberStep199RedChildVoxelTypes = new bytes32[](1);
    oakLumberStep199RedChildVoxelTypes[0] = OakLumberStep199RedVoxelID;
    bytes32 baseVoxelTypeId = OakLumberStep199RedVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Step199 Red",
      OakLumberStep199RedVoxelID,
      baseVoxelTypeId,
      oakLumberStep199RedChildVoxelTypes,
      oakLumberStep199RedChildVoxelTypes,
      OakLumberStep199RedVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D199E2_enterWorld.selector,
        IWorld(world).pretty_C31D199E2_exitWorld.selector,
        IWorld(world).pretty_C31D199E2_variantSelector.selector,
        IWorld(world).pretty_C31D199E2_activate.selector,
        IWorld(world).pretty_C31D199E2_eventHandler.selector,
        IWorld(world).pretty_C31D199E2_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberStep199RedVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberStep199RedVoxelVariantID;
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
