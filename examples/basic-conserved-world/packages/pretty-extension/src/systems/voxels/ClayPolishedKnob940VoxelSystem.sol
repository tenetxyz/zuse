// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayPolishedKnob940VoxelID = bytes32(keccak256("clay_polished_knob_940"));
bytes32 constant ClayPolishedKnob940VoxelVariantID = bytes32(keccak256("clay_polished_knob_940"));

contract ClayPolishedKnob940VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayPolishedKnob940Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayPolishedKnob940VoxelVariantID, clayPolishedKnob940Variant);

    bytes32[] memory clayPolishedKnob940ChildVoxelTypes = new bytes32[](1);
    clayPolishedKnob940ChildVoxelTypes[0] = ClayPolishedKnob940VoxelID;
    bytes32 baseVoxelTypeId = ClayPolishedKnob940VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Polished Knob940",
      ClayPolishedKnob940VoxelID,
      baseVoxelTypeId,
      clayPolishedKnob940ChildVoxelTypes,
      clayPolishedKnob940ChildVoxelTypes,
      ClayPolishedKnob940VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C45D940_enterWorld.selector,
        IWorld(world).pretty_C45D940_exitWorld.selector,
        IWorld(world).pretty_C45D940_variantSelector.selector,
        IWorld(world).pretty_C45D940_activate.selector,
        IWorld(world).pretty_C45D940_eventHandler.selector,
        IWorld(world).pretty_C45D940_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayPolishedKnob940VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayPolishedKnob940VoxelVariantID;
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
