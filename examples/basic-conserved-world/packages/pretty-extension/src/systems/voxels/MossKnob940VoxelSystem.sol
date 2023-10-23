// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant MossKnob940VoxelID = bytes32(keccak256("moss_knob_940"));
bytes32 constant MossKnob940VoxelVariantID = bytes32(keccak256("moss_knob_940"));

contract MossKnob940VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory mossKnob940Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, MossKnob940VoxelVariantID, mossKnob940Variant);

    bytes32[] memory mossKnob940ChildVoxelTypes = new bytes32[](1);
    mossKnob940ChildVoxelTypes[0] = MossKnob940VoxelID;
    bytes32 baseVoxelTypeId = MossKnob940VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Moss Knob940",
      MossKnob940VoxelID,
      baseVoxelTypeId,
      mossKnob940ChildVoxelTypes,
      mossKnob940ChildVoxelTypes,
      MossKnob940VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C40D940_enterWorld.selector,
        IWorld(world).pretty_C40D940_exitWorld.selector,
        IWorld(world).pretty_C40D940_variantSelector.selector,
        IWorld(world).pretty_C40D940_activate.selector,
        IWorld(world).pretty_C40D940_eventHandler.selector,
        IWorld(world).pretty_C40D940_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, MossKnob940VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return MossKnob940VoxelVariantID;
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
