// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant QuartziteVoxelID = bytes32(keccak256("quartzite"));
bytes32 constant QuartziteVoxelVariantID = bytes32(keccak256("quartzite"));

contract QuartziteVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory quartziteVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, QuartziteVoxelVariantID, quartziteVariant);

    bytes32[] memory quartziteChildVoxelTypes = new bytes32[](1);
    quartziteChildVoxelTypes[0] = QuartziteVoxelID;
    bytes32 baseVoxelTypeId = QuartziteVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Quartzite",
      QuartziteVoxelID,
      baseVoxelTypeId,
      quartziteChildVoxelTypes,
      quartziteChildVoxelTypes,
      QuartziteVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C7_enterWorld.selector,
        IWorld(world).pretty_C7_exitWorld.selector,
        IWorld(world).pretty_C7_variantSelector.selector,
        IWorld(world).pretty_C7_activate.selector,
        IWorld(world).pretty_C7_eventHandler.selector,
        IWorld(world).pretty_C7_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, QuartziteVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return QuartziteVoxelVariantID;
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
