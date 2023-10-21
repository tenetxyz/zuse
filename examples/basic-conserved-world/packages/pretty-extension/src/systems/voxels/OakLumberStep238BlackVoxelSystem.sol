// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberStep238BlackVoxelID = bytes32(keccak256("oak_lumber_step_238_black"));
bytes32 constant OakLumberStep238BlackVoxelVariantID = bytes32(keccak256("oak_lumber_step_238_black"));

contract OakLumberStep238BlackVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberStep238BlackVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberStep238BlackVoxelVariantID, oakLumberStep238BlackVariant);

    bytes32[] memory oakLumberStep238BlackChildVoxelTypes = new bytes32[](1);
    oakLumberStep238BlackChildVoxelTypes[0] = OakLumberStep238BlackVoxelID;
    bytes32 baseVoxelTypeId = OakLumberStep238BlackVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Step238 Black",
      OakLumberStep238BlackVoxelID,
      baseVoxelTypeId,
      oakLumberStep238BlackChildVoxelTypes,
      oakLumberStep238BlackChildVoxelTypes,
      OakLumberStep238BlackVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C312389_enterWorld.selector,
        IWorld(world).pretty_C312389_exitWorld.selector,
        IWorld(world).pretty_C312389_variantSelector.selector,
        IWorld(world).pretty_C312389_activate.selector,
        IWorld(world).pretty_C312389_eventHandler.selector,
        IWorld(world).pretty_C312389_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberStep238BlackVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberStep238BlackVoxelVariantID;
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
