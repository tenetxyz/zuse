// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BirchStrippedFrame640VoxelID = bytes32(keccak256("birch_stripped_frame_640"));
bytes32 constant BirchStrippedFrame640VoxelVariantID = bytes32(keccak256("birch_stripped_frame_640"));

contract BirchStrippedFrame640VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory birchStrippedFrame640Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BirchStrippedFrame640VoxelVariantID, birchStrippedFrame640Variant);

    bytes32[] memory birchStrippedFrame640ChildVoxelTypes = new bytes32[](1);
    birchStrippedFrame640ChildVoxelTypes[0] = BirchStrippedFrame640VoxelID;
    bytes32 baseVoxelTypeId = BirchStrippedFrame640VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Birch Stripped Frame640",
      BirchStrippedFrame640VoxelID,
      baseVoxelTypeId,
      birchStrippedFrame640ChildVoxelTypes,
      birchStrippedFrame640ChildVoxelTypes,
      BirchStrippedFrame640VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C71D640_enterWorld.selector,
        IWorld(world).pretty_C71D640_exitWorld.selector,
        IWorld(world).pretty_C71D640_variantSelector.selector,
        IWorld(world).pretty_C71D640_activate.selector,
        IWorld(world).pretty_C71D640_eventHandler.selector,
        IWorld(world).pretty_C71D640_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BirchStrippedFrame640VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BirchStrippedFrame640VoxelVariantID;
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
