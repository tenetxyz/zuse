// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricKnob903VoxelID = bytes32(keccak256("cotton_fabric_knob_903"));
bytes32 constant CottonFabricKnob903VoxelVariantID = bytes32(keccak256("cotton_fabric_knob_903"));

contract CottonFabricKnob903VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricKnob903Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricKnob903VoxelVariantID, cottonFabricKnob903Variant);

    bytes32[] memory cottonFabricKnob903ChildVoxelTypes = new bytes32[](1);
    cottonFabricKnob903ChildVoxelTypes[0] = CottonFabricKnob903VoxelID;
    bytes32 baseVoxelTypeId = CottonFabricKnob903VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Knob903",
      CottonFabricKnob903VoxelID,
      baseVoxelTypeId,
      cottonFabricKnob903ChildVoxelTypes,
      cottonFabricKnob903ChildVoxelTypes,
      CottonFabricKnob903VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D903_enterWorld.selector,
        IWorld(world).pretty_C38D903_exitWorld.selector,
        IWorld(world).pretty_C38D903_variantSelector.selector,
        IWorld(world).pretty_C38D903_activate.selector,
        IWorld(world).pretty_C38D903_eventHandler.selector,
        IWorld(world).pretty_C38D903_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricKnob903VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricKnob903VoxelVariantID;
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
