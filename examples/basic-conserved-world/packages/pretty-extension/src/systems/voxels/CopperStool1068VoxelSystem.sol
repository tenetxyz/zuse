// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CopperStool1068VoxelID = bytes32(keccak256("copper_stool_1068"));
bytes32 constant CopperStool1068VoxelVariantID = bytes32(keccak256("copper_stool_1068"));

contract CopperStool1068VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory copperStool1068Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CopperStool1068VoxelVariantID, copperStool1068Variant);

    bytes32[] memory copperStool1068ChildVoxelTypes = new bytes32[](1);
    copperStool1068ChildVoxelTypes[0] = CopperStool1068VoxelID;
    bytes32 baseVoxelTypeId = CopperStool1068VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Copper Stool1068",
      CopperStool1068VoxelID,
      baseVoxelTypeId,
      copperStool1068ChildVoxelTypes,
      copperStool1068ChildVoxelTypes,
      CopperStool1068VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C68D1068_enterWorld.selector,
        IWorld(world).pretty_C68D1068_exitWorld.selector,
        IWorld(world).pretty_C68D1068_variantSelector.selector,
        IWorld(world).pretty_C68D1068_activate.selector,
        IWorld(world).pretty_C68D1068_eventHandler.selector,
        IWorld(world).pretty_C68D1068_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CopperStool1068VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CopperStool1068VoxelVariantID;
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
