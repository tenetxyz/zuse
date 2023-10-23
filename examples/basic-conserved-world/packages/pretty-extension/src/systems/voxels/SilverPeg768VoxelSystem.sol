// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant SilverPeg768VoxelID = bytes32(keccak256("silver_peg_768"));
bytes32 constant SilverPeg768VoxelVariantID = bytes32(keccak256("silver_peg_768"));

contract SilverPeg768VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory silverPeg768Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, SilverPeg768VoxelVariantID, silverPeg768Variant);

    bytes32[] memory silverPeg768ChildVoxelTypes = new bytes32[](1);
    silverPeg768ChildVoxelTypes[0] = SilverPeg768VoxelID;
    bytes32 baseVoxelTypeId = SilverPeg768VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Silver Peg768",
      SilverPeg768VoxelID,
      baseVoxelTypeId,
      silverPeg768ChildVoxelTypes,
      silverPeg768ChildVoxelTypes,
      SilverPeg768VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C33D768_enterWorld.selector,
        IWorld(world).pretty_C33D768_exitWorld.selector,
        IWorld(world).pretty_C33D768_variantSelector.selector,
        IWorld(world).pretty_C33D768_activate.selector,
        IWorld(world).pretty_C33D768_eventHandler.selector,
        IWorld(world).pretty_C33D768_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, SilverPeg768VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return SilverPeg768VoxelVariantID;
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
