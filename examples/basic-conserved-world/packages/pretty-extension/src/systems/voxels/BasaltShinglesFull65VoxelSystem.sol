// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BasaltShinglesFull65VoxelID = bytes32(keccak256("basalt_shingles_full_65"));
bytes32 constant BasaltShinglesFull65VoxelVariantID = bytes32(keccak256("basalt_shingles_full_65"));

contract BasaltShinglesFull65VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory basaltShinglesFull65Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BasaltShinglesFull65VoxelVariantID, basaltShinglesFull65Variant);

    bytes32[] memory basaltShinglesFull65ChildVoxelTypes = new bytes32[](1);
    basaltShinglesFull65ChildVoxelTypes[0] = BasaltShinglesFull65VoxelID;
    bytes32 baseVoxelTypeId = BasaltShinglesFull65VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Basalt Shingles Full65",
      BasaltShinglesFull65VoxelID,
      baseVoxelTypeId,
      basaltShinglesFull65ChildVoxelTypes,
      basaltShinglesFull65ChildVoxelTypes,
      BasaltShinglesFull65VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C43D65_enterWorld.selector,
        IWorld(world).pretty_C43D65_exitWorld.selector,
        IWorld(world).pretty_C43D65_variantSelector.selector,
        IWorld(world).pretty_C43D65_activate.selector,
        IWorld(world).pretty_C43D65_eventHandler.selector,
        IWorld(world).pretty_C43D65_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BasaltShinglesFull65VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BasaltShinglesFull65VoxelVariantID;
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
