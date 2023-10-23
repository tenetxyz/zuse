// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayPolishedKnob937VoxelID = bytes32(keccak256("clay_polished_knob_937"));
bytes32 constant ClayPolishedKnob937VoxelVariantID = bytes32(keccak256("clay_polished_knob_937"));

contract ClayPolishedKnob937VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayPolishedKnob937Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayPolishedKnob937VoxelVariantID, clayPolishedKnob937Variant);

    bytes32[] memory clayPolishedKnob937ChildVoxelTypes = new bytes32[](1);
    clayPolishedKnob937ChildVoxelTypes[0] = ClayPolishedKnob937VoxelID;
    bytes32 baseVoxelTypeId = ClayPolishedKnob937VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Polished Knob937",
      ClayPolishedKnob937VoxelID,
      baseVoxelTypeId,
      clayPolishedKnob937ChildVoxelTypes,
      clayPolishedKnob937ChildVoxelTypes,
      ClayPolishedKnob937VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C45D937_enterWorld.selector,
        IWorld(world).pretty_C45D937_exitWorld.selector,
        IWorld(world).pretty_C45D937_variantSelector.selector,
        IWorld(world).pretty_C45D937_activate.selector,
        IWorld(world).pretty_C45D937_eventHandler.selector,
        IWorld(world).pretty_C45D937_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayPolishedKnob937VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayPolishedKnob937VoxelVariantID;
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
