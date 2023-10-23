// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ThatchBeam1280VoxelID = bytes32(keccak256("thatch_beam_1280"));
bytes32 constant ThatchBeam1280VoxelVariantID = bytes32(keccak256("thatch_beam_1280"));

contract ThatchBeam1280VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory thatchBeam1280Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ThatchBeam1280VoxelVariantID, thatchBeam1280Variant);

    bytes32[] memory thatchBeam1280ChildVoxelTypes = new bytes32[](1);
    thatchBeam1280ChildVoxelTypes[0] = ThatchBeam1280VoxelID;
    bytes32 baseVoxelTypeId = ThatchBeam1280VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Thatch Beam1280",
      ThatchBeam1280VoxelID,
      baseVoxelTypeId,
      thatchBeam1280ChildVoxelTypes,
      thatchBeam1280ChildVoxelTypes,
      ThatchBeam1280VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C63D1280_enterWorld.selector,
        IWorld(world).pretty_C63D1280_exitWorld.selector,
        IWorld(world).pretty_C63D1280_variantSelector.selector,
        IWorld(world).pretty_C63D1280_activate.selector,
        IWorld(world).pretty_C63D1280_eventHandler.selector,
        IWorld(world).pretty_C63D1280_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ThatchBeam1280VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ThatchBeam1280VoxelVariantID;
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
