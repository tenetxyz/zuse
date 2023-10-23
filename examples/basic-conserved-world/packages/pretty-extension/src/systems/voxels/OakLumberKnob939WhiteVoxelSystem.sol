// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberKnob939WhiteVoxelID = bytes32(keccak256("oak_lumber_knob_939_white"));
bytes32 constant OakLumberKnob939WhiteVoxelVariantID = bytes32(keccak256("oak_lumber_knob_939_white"));

contract OakLumberKnob939WhiteVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberKnob939WhiteVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberKnob939WhiteVoxelVariantID, oakLumberKnob939WhiteVariant);

    bytes32[] memory oakLumberKnob939WhiteChildVoxelTypes = new bytes32[](1);
    oakLumberKnob939WhiteChildVoxelTypes[0] = OakLumberKnob939WhiteVoxelID;
    bytes32 baseVoxelTypeId = OakLumberKnob939WhiteVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Knob939 White",
      OakLumberKnob939WhiteVoxelID,
      baseVoxelTypeId,
      oakLumberKnob939WhiteChildVoxelTypes,
      oakLumberKnob939WhiteChildVoxelTypes,
      OakLumberKnob939WhiteVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D939E5_enterWorld.selector,
        IWorld(world).pretty_C31D939E5_exitWorld.selector,
        IWorld(world).pretty_C31D939E5_variantSelector.selector,
        IWorld(world).pretty_C31D939E5_activate.selector,
        IWorld(world).pretty_C31D939E5_eventHandler.selector,
        IWorld(world).pretty_C31D939E5_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberKnob939WhiteVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberKnob939WhiteVoxelVariantID;
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
