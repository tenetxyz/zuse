// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberLumberTrack1385VoxelID = bytes32(keccak256("rubber_lumber_track_1385"));
bytes32 constant RubberLumberTrack1385VoxelVariantID = bytes32(keccak256("rubber_lumber_track_1385"));

contract RubberLumberTrack1385VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberLumberTrack1385Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberLumberTrack1385VoxelVariantID, rubberLumberTrack1385Variant);

    bytes32[] memory rubberLumberTrack1385ChildVoxelTypes = new bytes32[](1);
    rubberLumberTrack1385ChildVoxelTypes[0] = RubberLumberTrack1385VoxelID;
    bytes32 baseVoxelTypeId = RubberLumberTrack1385VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Lumber Track1385",
      RubberLumberTrack1385VoxelID,
      baseVoxelTypeId,
      rubberLumberTrack1385ChildVoxelTypes,
      rubberLumberTrack1385ChildVoxelTypes,
      RubberLumberTrack1385VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C34D1385_enterWorld.selector,
        IWorld(world).pretty_C34D1385_exitWorld.selector,
        IWorld(world).pretty_C34D1385_variantSelector.selector,
        IWorld(world).pretty_C34D1385_activate.selector,
        IWorld(world).pretty_C34D1385_eventHandler.selector,
        IWorld(world).pretty_C34D1385_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberLumberTrack1385VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberLumberTrack1385VoxelVariantID;
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
