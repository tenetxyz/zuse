// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant SilverStool1070VoxelID = bytes32(keccak256("silver_stool_1070"));
bytes32 constant SilverStool1070VoxelVariantID = bytes32(keccak256("silver_stool_1070"));

contract SilverStool1070VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory silverStool1070Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, SilverStool1070VoxelVariantID, silverStool1070Variant);

    bytes32[] memory silverStool1070ChildVoxelTypes = new bytes32[](1);
    silverStool1070ChildVoxelTypes[0] = SilverStool1070VoxelID;
    bytes32 baseVoxelTypeId = SilverStool1070VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Silver Stool1070",
      SilverStool1070VoxelID,
      baseVoxelTypeId,
      silverStool1070ChildVoxelTypes,
      silverStool1070ChildVoxelTypes,
      SilverStool1070VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C33D1070_enterWorld.selector,
        IWorld(world).pretty_C33D1070_exitWorld.selector,
        IWorld(world).pretty_C33D1070_variantSelector.selector,
        IWorld(world).pretty_C33D1070_activate.selector,
        IWorld(world).pretty_C33D1070_eventHandler.selector,
        IWorld(world).pretty_C33D1070_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, SilverStool1070VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return SilverStool1070VoxelVariantID;
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
