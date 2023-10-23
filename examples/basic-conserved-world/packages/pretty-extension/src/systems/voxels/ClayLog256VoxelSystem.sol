// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayLog256VoxelID = bytes32(keccak256("clay_log_256"));
bytes32 constant ClayLog256VoxelVariantID = bytes32(keccak256("clay_log_256"));

contract ClayLog256VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayLog256Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayLog256VoxelVariantID, clayLog256Variant);

    bytes32[] memory clayLog256ChildVoxelTypes = new bytes32[](1);
    clayLog256ChildVoxelTypes[0] = ClayLog256VoxelID;
    bytes32 baseVoxelTypeId = ClayLog256VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Log256",
      ClayLog256VoxelID,
      baseVoxelTypeId,
      clayLog256ChildVoxelTypes,
      clayLog256ChildVoxelTypes,
      ClayLog256VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C17D256_enterWorld.selector,
        IWorld(world).pretty_C17D256_exitWorld.selector,
        IWorld(world).pretty_C17D256_variantSelector.selector,
        IWorld(world).pretty_C17D256_activate.selector,
        IWorld(world).pretty_C17D256_eventHandler.selector,
        IWorld(world).pretty_C17D256_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayLog256VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayLog256VoxelVariantID;
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
