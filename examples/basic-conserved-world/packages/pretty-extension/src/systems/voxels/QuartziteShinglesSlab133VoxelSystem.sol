// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant QuartziteShinglesSlab133VoxelID = bytes32(keccak256("quartzite_shingles_slab_133"));
bytes32 constant QuartziteShinglesSlab133VoxelVariantID = bytes32(keccak256("quartzite_shingles_slab_133"));

contract QuartziteShinglesSlab133VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory quartziteShinglesSlab133Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, QuartziteShinglesSlab133VoxelVariantID, quartziteShinglesSlab133Variant);

    bytes32[] memory quartziteShinglesSlab133ChildVoxelTypes = new bytes32[](1);
    quartziteShinglesSlab133ChildVoxelTypes[0] = QuartziteShinglesSlab133VoxelID;
    bytes32 baseVoxelTypeId = QuartziteShinglesSlab133VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Quartzite Shingles Slab133",
      QuartziteShinglesSlab133VoxelID,
      baseVoxelTypeId,
      quartziteShinglesSlab133ChildVoxelTypes,
      quartziteShinglesSlab133ChildVoxelTypes,
      QuartziteShinglesSlab133VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C58D133_enterWorld.selector,
        IWorld(world).pretty_C58D133_exitWorld.selector,
        IWorld(world).pretty_C58D133_variantSelector.selector,
        IWorld(world).pretty_C58D133_activate.selector,
        IWorld(world).pretty_C58D133_eventHandler.selector,
        IWorld(world).pretty_C58D133_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, QuartziteShinglesSlab133VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return QuartziteShinglesSlab133VoxelVariantID;
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
