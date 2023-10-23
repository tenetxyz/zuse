// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberLogStep199VoxelID = bytes32(keccak256("rubber_log_step_199"));
bytes32 constant RubberLogStep199VoxelVariantID = bytes32(keccak256("rubber_log_step_199"));

contract RubberLogStep199VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberLogStep199Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberLogStep199VoxelVariantID, rubberLogStep199Variant);

    bytes32[] memory rubberLogStep199ChildVoxelTypes = new bytes32[](1);
    rubberLogStep199ChildVoxelTypes[0] = RubberLogStep199VoxelID;
    bytes32 baseVoxelTypeId = RubberLogStep199VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Log Step199",
      RubberLogStep199VoxelID,
      baseVoxelTypeId,
      rubberLogStep199ChildVoxelTypes,
      rubberLogStep199ChildVoxelTypes,
      RubberLogStep199VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C14D199_enterWorld.selector,
        IWorld(world).pretty_C14D199_exitWorld.selector,
        IWorld(world).pretty_C14D199_variantSelector.selector,
        IWorld(world).pretty_C14D199_activate.selector,
        IWorld(world).pretty_C14D199_eventHandler.selector,
        IWorld(world).pretty_C14D199_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberLogStep199VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberLogStep199VoxelVariantID;
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
