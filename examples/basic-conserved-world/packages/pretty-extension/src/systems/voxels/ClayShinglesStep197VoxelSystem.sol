// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayShinglesStep197VoxelID = bytes32(keccak256("clay_shingles_step_197"));
bytes32 constant ClayShinglesStep197VoxelVariantID = bytes32(keccak256("clay_shingles_step_197"));

contract ClayShinglesStep197VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayShinglesStep197Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayShinglesStep197VoxelVariantID, clayShinglesStep197Variant);

    bytes32[] memory clayShinglesStep197ChildVoxelTypes = new bytes32[](1);
    clayShinglesStep197ChildVoxelTypes[0] = ClayShinglesStep197VoxelID;
    bytes32 baseVoxelTypeId = ClayShinglesStep197VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Shingles Step197",
      ClayShinglesStep197VoxelID,
      baseVoxelTypeId,
      clayShinglesStep197ChildVoxelTypes,
      clayShinglesStep197ChildVoxelTypes,
      ClayShinglesStep197VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C46D197_enterWorld.selector,
        IWorld(world).pretty_C46D197_exitWorld.selector,
        IWorld(world).pretty_C46D197_variantSelector.selector,
        IWorld(world).pretty_C46D197_activate.selector,
        IWorld(world).pretty_C46D197_eventHandler.selector,
        IWorld(world).pretty_C46D197_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayShinglesStep197VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayShinglesStep197VoxelVariantID;
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
