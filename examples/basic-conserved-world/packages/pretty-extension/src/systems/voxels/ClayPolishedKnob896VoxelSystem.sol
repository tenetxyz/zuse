// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayPolishedKnob896VoxelID = bytes32(keccak256("clay_polished_knob_896"));
bytes32 constant ClayPolishedKnob896VoxelVariantID = bytes32(keccak256("clay_polished_knob_896"));

contract ClayPolishedKnob896VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayPolishedKnob896Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayPolishedKnob896VoxelVariantID, clayPolishedKnob896Variant);

    bytes32[] memory clayPolishedKnob896ChildVoxelTypes = new bytes32[](1);
    clayPolishedKnob896ChildVoxelTypes[0] = ClayPolishedKnob896VoxelID;
    bytes32 baseVoxelTypeId = ClayPolishedKnob896VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Polished Knob896",
      ClayPolishedKnob896VoxelID,
      baseVoxelTypeId,
      clayPolishedKnob896ChildVoxelTypes,
      clayPolishedKnob896ChildVoxelTypes,
      ClayPolishedKnob896VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C45D896_enterWorld.selector,
        IWorld(world).pretty_C45D896_exitWorld.selector,
        IWorld(world).pretty_C45D896_variantSelector.selector,
        IWorld(world).pretty_C45D896_activate.selector,
        IWorld(world).pretty_C45D896_eventHandler.selector,
        IWorld(world).pretty_C45D896_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayPolishedKnob896VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayPolishedKnob896VoxelVariantID;
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
