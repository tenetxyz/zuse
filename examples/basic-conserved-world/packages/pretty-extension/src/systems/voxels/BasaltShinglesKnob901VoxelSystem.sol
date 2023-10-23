// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BasaltShinglesKnob901VoxelID = bytes32(keccak256("basalt_shingles_knob_901"));
bytes32 constant BasaltShinglesKnob901VoxelVariantID = bytes32(keccak256("basalt_shingles_knob_901"));

contract BasaltShinglesKnob901VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory basaltShinglesKnob901Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BasaltShinglesKnob901VoxelVariantID, basaltShinglesKnob901Variant);

    bytes32[] memory basaltShinglesKnob901ChildVoxelTypes = new bytes32[](1);
    basaltShinglesKnob901ChildVoxelTypes[0] = BasaltShinglesKnob901VoxelID;
    bytes32 baseVoxelTypeId = BasaltShinglesKnob901VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Basalt Shingles Knob901",
      BasaltShinglesKnob901VoxelID,
      baseVoxelTypeId,
      basaltShinglesKnob901ChildVoxelTypes,
      basaltShinglesKnob901ChildVoxelTypes,
      BasaltShinglesKnob901VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C43D901_enterWorld.selector,
        IWorld(world).pretty_C43D901_exitWorld.selector,
        IWorld(world).pretty_C43D901_variantSelector.selector,
        IWorld(world).pretty_C43D901_activate.selector,
        IWorld(world).pretty_C43D901_eventHandler.selector,
        IWorld(world).pretty_C43D901_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BasaltShinglesKnob901VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BasaltShinglesKnob901VoxelVariantID;
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
