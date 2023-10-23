// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BasaltShinglesStep234VoxelID = bytes32(keccak256("basalt_shingles_step_234"));
bytes32 constant BasaltShinglesStep234VoxelVariantID = bytes32(keccak256("basalt_shingles_step_234"));

contract BasaltShinglesStep234VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory basaltShinglesStep234Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BasaltShinglesStep234VoxelVariantID, basaltShinglesStep234Variant);

    bytes32[] memory basaltShinglesStep234ChildVoxelTypes = new bytes32[](1);
    basaltShinglesStep234ChildVoxelTypes[0] = BasaltShinglesStep234VoxelID;
    bytes32 baseVoxelTypeId = BasaltShinglesStep234VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Basalt Shingles Step234",
      BasaltShinglesStep234VoxelID,
      baseVoxelTypeId,
      basaltShinglesStep234ChildVoxelTypes,
      basaltShinglesStep234ChildVoxelTypes,
      BasaltShinglesStep234VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C43D234_enterWorld.selector,
        IWorld(world).pretty_C43D234_exitWorld.selector,
        IWorld(world).pretty_C43D234_variantSelector.selector,
        IWorld(world).pretty_C43D234_activate.selector,
        IWorld(world).pretty_C43D234_eventHandler.selector,
        IWorld(world).pretty_C43D234_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BasaltShinglesStep234VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BasaltShinglesStep234VoxelVariantID;
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
