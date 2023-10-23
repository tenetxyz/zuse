// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ThatchPeg809VoxelID = bytes32(keccak256("thatch_peg_809"));
bytes32 constant ThatchPeg809VoxelVariantID = bytes32(keccak256("thatch_peg_809"));

contract ThatchPeg809VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory thatchPeg809Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ThatchPeg809VoxelVariantID, thatchPeg809Variant);

    bytes32[] memory thatchPeg809ChildVoxelTypes = new bytes32[](1);
    thatchPeg809ChildVoxelTypes[0] = ThatchPeg809VoxelID;
    bytes32 baseVoxelTypeId = ThatchPeg809VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Thatch Peg809",
      ThatchPeg809VoxelID,
      baseVoxelTypeId,
      thatchPeg809ChildVoxelTypes,
      thatchPeg809ChildVoxelTypes,
      ThatchPeg809VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C63D809_enterWorld.selector,
        IWorld(world).pretty_C63D809_exitWorld.selector,
        IWorld(world).pretty_C63D809_variantSelector.selector,
        IWorld(world).pretty_C63D809_activate.selector,
        IWorld(world).pretty_C63D809_eventHandler.selector,
        IWorld(world).pretty_C63D809_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ThatchPeg809VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ThatchPeg809VoxelVariantID;
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
