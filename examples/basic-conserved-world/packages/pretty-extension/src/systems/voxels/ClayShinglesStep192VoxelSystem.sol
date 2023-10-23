// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayShinglesStep192VoxelID = bytes32(keccak256("clay_shingles_step_192"));
bytes32 constant ClayShinglesStep192VoxelVariantID = bytes32(keccak256("clay_shingles_step_192"));

contract ClayShinglesStep192VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayShinglesStep192Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayShinglesStep192VoxelVariantID, clayShinglesStep192Variant);

    bytes32[] memory clayShinglesStep192ChildVoxelTypes = new bytes32[](1);
    clayShinglesStep192ChildVoxelTypes[0] = ClayShinglesStep192VoxelID;
    bytes32 baseVoxelTypeId = ClayShinglesStep192VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Shingles Step192",
      ClayShinglesStep192VoxelID,
      baseVoxelTypeId,
      clayShinglesStep192ChildVoxelTypes,
      clayShinglesStep192ChildVoxelTypes,
      ClayShinglesStep192VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C46D192_enterWorld.selector,
        IWorld(world).pretty_C46D192_exitWorld.selector,
        IWorld(world).pretty_C46D192_variantSelector.selector,
        IWorld(world).pretty_C46D192_activate.selector,
        IWorld(world).pretty_C46D192_eventHandler.selector,
        IWorld(world).pretty_C46D192_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayShinglesStep192VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayShinglesStep192VoxelVariantID;
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
