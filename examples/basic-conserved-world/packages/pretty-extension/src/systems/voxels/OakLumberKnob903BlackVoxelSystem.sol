// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberKnob903BlackVoxelID = bytes32(keccak256("oak_lumber_knob_903_black"));
bytes32 constant OakLumberKnob903BlackVoxelVariantID = bytes32(keccak256("oak_lumber_knob_903_black"));

contract OakLumberKnob903BlackVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberKnob903BlackVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberKnob903BlackVoxelVariantID, oakLumberKnob903BlackVariant);

    bytes32[] memory oakLumberKnob903BlackChildVoxelTypes = new bytes32[](1);
    oakLumberKnob903BlackChildVoxelTypes[0] = OakLumberKnob903BlackVoxelID;
    bytes32 baseVoxelTypeId = OakLumberKnob903BlackVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Knob903 Black",
      OakLumberKnob903BlackVoxelID,
      baseVoxelTypeId,
      oakLumberKnob903BlackChildVoxelTypes,
      oakLumberKnob903BlackChildVoxelTypes,
      OakLumberKnob903BlackVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C319039_enterWorld.selector,
        IWorld(world).pretty_C319039_exitWorld.selector,
        IWorld(world).pretty_C319039_variantSelector.selector,
        IWorld(world).pretty_C319039_activate.selector,
        IWorld(world).pretty_C319039_eventHandler.selector,
        IWorld(world).pretty_C319039_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberKnob903BlackVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberKnob903BlackVoxelVariantID;
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
