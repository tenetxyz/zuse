// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BirchStrippedStool1065VoxelID = bytes32(keccak256("birch_stripped_stool_1065"));
bytes32 constant BirchStrippedStool1065VoxelVariantID = bytes32(keccak256("birch_stripped_stool_1065"));

contract BirchStrippedStool1065VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory birchStrippedStool1065Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BirchStrippedStool1065VoxelVariantID, birchStrippedStool1065Variant);

    bytes32[] memory birchStrippedStool1065ChildVoxelTypes = new bytes32[](1);
    birchStrippedStool1065ChildVoxelTypes[0] = BirchStrippedStool1065VoxelID;
    bytes32 baseVoxelTypeId = BirchStrippedStool1065VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Birch Stripped Stool1065",
      BirchStrippedStool1065VoxelID,
      baseVoxelTypeId,
      birchStrippedStool1065ChildVoxelTypes,
      birchStrippedStool1065ChildVoxelTypes,
      BirchStrippedStool1065VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C71D1065_enterWorld.selector,
        IWorld(world).pretty_C71D1065_exitWorld.selector,
        IWorld(world).pretty_C71D1065_variantSelector.selector,
        IWorld(world).pretty_C71D1065_activate.selector,
        IWorld(world).pretty_C71D1065_eventHandler.selector,
        IWorld(world).pretty_C71D1065_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BirchStrippedStool1065VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BirchStrippedStool1065VoxelVariantID;
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
