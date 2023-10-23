// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayLog297VoxelID = bytes32(keccak256("clay_log_297"));
bytes32 constant ClayLog297VoxelVariantID = bytes32(keccak256("clay_log_297"));

contract ClayLog297VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayLog297Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayLog297VoxelVariantID, clayLog297Variant);

    bytes32[] memory clayLog297ChildVoxelTypes = new bytes32[](1);
    clayLog297ChildVoxelTypes[0] = ClayLog297VoxelID;
    bytes32 baseVoxelTypeId = ClayLog297VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Log297",
      ClayLog297VoxelID,
      baseVoxelTypeId,
      clayLog297ChildVoxelTypes,
      clayLog297ChildVoxelTypes,
      ClayLog297VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C17D297_enterWorld.selector,
        IWorld(world).pretty_C17D297_exitWorld.selector,
        IWorld(world).pretty_C17D297_variantSelector.selector,
        IWorld(world).pretty_C17D297_activate.selector,
        IWorld(world).pretty_C17D297_eventHandler.selector,
        IWorld(world).pretty_C17D297_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayLog297VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayLog297VoxelVariantID;
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
