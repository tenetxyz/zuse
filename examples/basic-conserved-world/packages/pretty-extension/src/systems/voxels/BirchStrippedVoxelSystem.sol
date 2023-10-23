// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BirchStrippedVoxelID = bytes32(keccak256("birch_stripped"));
bytes32 constant BirchStrippedVoxelVariantID = bytes32(keccak256("birch_stripped"));

contract BirchStrippedVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory birchStrippedVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, BirchStrippedVoxelVariantID, birchStrippedVariant);

    bytes32[] memory birchStrippedChildVoxelTypes = new bytes32[](1);
    birchStrippedChildVoxelTypes[0] = BirchStrippedVoxelID;
    bytes32 baseVoxelTypeId = BirchStrippedVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Birch Stripped",
      BirchStrippedVoxelID,
      baseVoxelTypeId,
      birchStrippedChildVoxelTypes,
      birchStrippedChildVoxelTypes,
      BirchStrippedVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C71_enterWorld.selector,
        IWorld(world).pretty_C71_exitWorld.selector,
        IWorld(world).pretty_C71_variantSelector.selector,
        IWorld(world).pretty_C71_activate.selector,
        IWorld(world).pretty_C71_eventHandler.selector,
        IWorld(world).pretty_C71_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BirchStrippedVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BirchStrippedVoxelVariantID;
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
