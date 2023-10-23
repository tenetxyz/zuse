// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberStrippedPeg812VoxelID = bytes32(keccak256("rubber_stripped_peg_812"));
bytes32 constant RubberStrippedPeg812VoxelVariantID = bytes32(keccak256("rubber_stripped_peg_812"));

contract RubberStrippedPeg812VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberStrippedPeg812Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberStrippedPeg812VoxelVariantID, rubberStrippedPeg812Variant);

    bytes32[] memory rubberStrippedPeg812ChildVoxelTypes = new bytes32[](1);
    rubberStrippedPeg812ChildVoxelTypes[0] = RubberStrippedPeg812VoxelID;
    bytes32 baseVoxelTypeId = RubberStrippedPeg812VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Stripped Peg812",
      RubberStrippedPeg812VoxelID,
      baseVoxelTypeId,
      rubberStrippedPeg812ChildVoxelTypes,
      rubberStrippedPeg812ChildVoxelTypes,
      RubberStrippedPeg812VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C75D812_enterWorld.selector,
        IWorld(world).pretty_C75D812_exitWorld.selector,
        IWorld(world).pretty_C75D812_variantSelector.selector,
        IWorld(world).pretty_C75D812_activate.selector,
        IWorld(world).pretty_C75D812_eventHandler.selector,
        IWorld(world).pretty_C75D812_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberStrippedPeg812VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberStrippedPeg812VoxelVariantID;
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
