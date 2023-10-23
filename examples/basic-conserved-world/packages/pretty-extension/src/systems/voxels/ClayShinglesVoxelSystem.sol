// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayShinglesVoxelID = bytes32(keccak256("clay_shingles"));
bytes32 constant ClayShinglesVoxelVariantID = bytes32(keccak256("clay_shingles"));

contract ClayShinglesVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayShinglesVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayShinglesVoxelVariantID, clayShinglesVariant);

    bytes32[] memory clayShinglesChildVoxelTypes = new bytes32[](1);
    clayShinglesChildVoxelTypes[0] = ClayShinglesVoxelID;
    bytes32 baseVoxelTypeId = ClayShinglesVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Shingles",
      ClayShinglesVoxelID,
      baseVoxelTypeId,
      clayShinglesChildVoxelTypes,
      clayShinglesChildVoxelTypes,
      ClayShinglesVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C46_enterWorld.selector,
        IWorld(world).pretty_C46_exitWorld.selector,
        IWorld(world).pretty_C46_variantSelector.selector,
        IWorld(world).pretty_C46_activate.selector,
        IWorld(world).pretty_C46_eventHandler.selector,
        IWorld(world).pretty_C46_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayShinglesVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayShinglesVoxelVariantID;
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
