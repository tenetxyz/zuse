// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberTrack1351VoxelID = bytes32(keccak256("oak_lumber_track_1351"));
bytes32 constant OakLumberTrack1351VoxelVariantID = bytes32(keccak256("oak_lumber_track_1351"));

contract OakLumberTrack1351VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberTrack1351Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberTrack1351VoxelVariantID, oakLumberTrack1351Variant);

    bytes32[] memory oakLumberTrack1351ChildVoxelTypes = new bytes32[](1);
    oakLumberTrack1351ChildVoxelTypes[0] = OakLumberTrack1351VoxelID;
    bytes32 baseVoxelTypeId = OakLumberTrack1351VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Track1351",
      OakLumberTrack1351VoxelID,
      baseVoxelTypeId,
      oakLumberTrack1351ChildVoxelTypes,
      oakLumberTrack1351ChildVoxelTypes,
      OakLumberTrack1351VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D1351_enterWorld.selector,
        IWorld(world).pretty_C31D1351_exitWorld.selector,
        IWorld(world).pretty_C31D1351_variantSelector.selector,
        IWorld(world).pretty_C31D1351_activate.selector,
        IWorld(world).pretty_C31D1351_eventHandler.selector,
        IWorld(world).pretty_C31D1351_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberTrack1351VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberTrack1351VoxelVariantID;
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
