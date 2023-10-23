// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BasaltShinglesStep237VoxelID = bytes32(keccak256("basalt_shingles_step_237"));
bytes32 constant BasaltShinglesStep237VoxelVariantID = bytes32(keccak256("basalt_shingles_step_237"));

contract BasaltShinglesStep237VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory basaltShinglesStep237Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BasaltShinglesStep237VoxelVariantID, basaltShinglesStep237Variant);

    bytes32[] memory basaltShinglesStep237ChildVoxelTypes = new bytes32[](1);
    basaltShinglesStep237ChildVoxelTypes[0] = BasaltShinglesStep237VoxelID;
    bytes32 baseVoxelTypeId = BasaltShinglesStep237VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Basalt Shingles Step237",
      BasaltShinglesStep237VoxelID,
      baseVoxelTypeId,
      basaltShinglesStep237ChildVoxelTypes,
      basaltShinglesStep237ChildVoxelTypes,
      BasaltShinglesStep237VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C43D237_enterWorld.selector,
        IWorld(world).pretty_C43D237_exitWorld.selector,
        IWorld(world).pretty_C43D237_variantSelector.selector,
        IWorld(world).pretty_C43D237_activate.selector,
        IWorld(world).pretty_C43D237_eventHandler.selector,
        IWorld(world).pretty_C43D237_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BasaltShinglesStep237VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BasaltShinglesStep237VoxelVariantID;
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
