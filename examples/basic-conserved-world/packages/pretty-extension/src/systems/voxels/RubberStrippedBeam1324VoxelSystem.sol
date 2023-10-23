// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberStrippedBeam1324VoxelID = bytes32(keccak256("rubber_stripped_beam_1324"));
bytes32 constant RubberStrippedBeam1324VoxelVariantID = bytes32(keccak256("rubber_stripped_beam_1324"));

contract RubberStrippedBeam1324VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberStrippedBeam1324Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberStrippedBeam1324VoxelVariantID, rubberStrippedBeam1324Variant);

    bytes32[] memory rubberStrippedBeam1324ChildVoxelTypes = new bytes32[](1);
    rubberStrippedBeam1324ChildVoxelTypes[0] = RubberStrippedBeam1324VoxelID;
    bytes32 baseVoxelTypeId = RubberStrippedBeam1324VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Stripped Beam1324",
      RubberStrippedBeam1324VoxelID,
      baseVoxelTypeId,
      rubberStrippedBeam1324ChildVoxelTypes,
      rubberStrippedBeam1324ChildVoxelTypes,
      RubberStrippedBeam1324VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C75D1324_enterWorld.selector,
        IWorld(world).pretty_C75D1324_exitWorld.selector,
        IWorld(world).pretty_C75D1324_variantSelector.selector,
        IWorld(world).pretty_C75D1324_activate.selector,
        IWorld(world).pretty_C75D1324_eventHandler.selector,
        IWorld(world).pretty_C75D1324_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberStrippedBeam1324VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberStrippedBeam1324VoxelVariantID;
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
