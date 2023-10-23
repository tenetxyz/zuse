// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricKnob939VoxelID = bytes32(keccak256("cotton_fabric_knob_939"));
bytes32 constant CottonFabricKnob939VoxelVariantID = bytes32(keccak256("cotton_fabric_knob_939"));

contract CottonFabricKnob939VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricKnob939Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricKnob939VoxelVariantID, cottonFabricKnob939Variant);

    bytes32[] memory cottonFabricKnob939ChildVoxelTypes = new bytes32[](1);
    cottonFabricKnob939ChildVoxelTypes[0] = CottonFabricKnob939VoxelID;
    bytes32 baseVoxelTypeId = CottonFabricKnob939VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Knob939",
      CottonFabricKnob939VoxelID,
      baseVoxelTypeId,
      cottonFabricKnob939ChildVoxelTypes,
      cottonFabricKnob939ChildVoxelTypes,
      CottonFabricKnob939VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D939_enterWorld.selector,
        IWorld(world).pretty_C38D939_exitWorld.selector,
        IWorld(world).pretty_C38D939_variantSelector.selector,
        IWorld(world).pretty_C38D939_activate.selector,
        IWorld(world).pretty_C38D939_eventHandler.selector,
        IWorld(world).pretty_C38D939_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricKnob939VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricKnob939VoxelVariantID;
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
