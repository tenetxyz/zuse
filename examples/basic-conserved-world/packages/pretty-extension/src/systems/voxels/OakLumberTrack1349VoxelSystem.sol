// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberTrack1349VoxelID = bytes32(keccak256("oak_lumber_track_1349"));
bytes32 constant OakLumberTrack1349VoxelVariantID = bytes32(keccak256("oak_lumber_track_1349"));

contract OakLumberTrack1349VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberTrack1349Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberTrack1349VoxelVariantID, oakLumberTrack1349Variant);

    bytes32[] memory oakLumberTrack1349ChildVoxelTypes = new bytes32[](1);
    oakLumberTrack1349ChildVoxelTypes[0] = OakLumberTrack1349VoxelID;
    bytes32 baseVoxelTypeId = OakLumberTrack1349VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Track1349",
      OakLumberTrack1349VoxelID,
      baseVoxelTypeId,
      oakLumberTrack1349ChildVoxelTypes,
      oakLumberTrack1349ChildVoxelTypes,
      OakLumberTrack1349VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D1349_enterWorld.selector,
        IWorld(world).pretty_C31D1349_exitWorld.selector,
        IWorld(world).pretty_C31D1349_variantSelector.selector,
        IWorld(world).pretty_C31D1349_activate.selector,
        IWorld(world).pretty_C31D1349_eventHandler.selector,
        IWorld(world).pretty_C31D1349_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberTrack1349VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberTrack1349VoxelVariantID;
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
