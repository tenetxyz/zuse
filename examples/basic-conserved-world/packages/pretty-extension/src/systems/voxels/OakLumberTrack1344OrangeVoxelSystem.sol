// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberTrack1344OrangeVoxelID = bytes32(keccak256("oak_lumber_track_1344_orange"));
bytes32 constant OakLumberTrack1344OrangeVoxelVariantID = bytes32(keccak256("oak_lumber_track_1344_orange"));

contract OakLumberTrack1344OrangeVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberTrack1344OrangeVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberTrack1344OrangeVoxelVariantID, oakLumberTrack1344OrangeVariant);

    bytes32[] memory oakLumberTrack1344OrangeChildVoxelTypes = new bytes32[](1);
    oakLumberTrack1344OrangeChildVoxelTypes[0] = OakLumberTrack1344OrangeVoxelID;
    bytes32 baseVoxelTypeId = OakLumberTrack1344OrangeVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Track1344 Orange",
      OakLumberTrack1344OrangeVoxelID,
      baseVoxelTypeId,
      oakLumberTrack1344OrangeChildVoxelTypes,
      oakLumberTrack1344OrangeChildVoxelTypes,
      OakLumberTrack1344OrangeVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C3113444_enterWorld.selector,
        IWorld(world).pretty_C3113444_exitWorld.selector,
        IWorld(world).pretty_C3113444_variantSelector.selector,
        IWorld(world).pretty_C3113444_activate.selector,
        IWorld(world).pretty_C3113444_eventHandler.selector,
        IWorld(world).pretty_C3113444_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberTrack1344OrangeVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberTrack1344OrangeVoxelVariantID;
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
