// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakStrippedLog300VoxelID = bytes32(keccak256("oak_stripped_log_300"));
bytes32 constant OakStrippedLog300VoxelVariantID = bytes32(keccak256("oak_stripped_log_300"));

contract OakStrippedLog300VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakStrippedLog300Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakStrippedLog300VoxelVariantID, oakStrippedLog300Variant);

    bytes32[] memory oakStrippedLog300ChildVoxelTypes = new bytes32[](1);
    oakStrippedLog300ChildVoxelTypes[0] = OakStrippedLog300VoxelID;
    bytes32 baseVoxelTypeId = OakStrippedLog300VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Stripped Log300",
      OakStrippedLog300VoxelID,
      baseVoxelTypeId,
      oakStrippedLog300ChildVoxelTypes,
      oakStrippedLog300ChildVoxelTypes,
      OakStrippedLog300VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C73D300_enterWorld.selector,
        IWorld(world).pretty_C73D300_exitWorld.selector,
        IWorld(world).pretty_C73D300_variantSelector.selector,
        IWorld(world).pretty_C73D300_activate.selector,
        IWorld(world).pretty_C73D300_eventHandler.selector,
        IWorld(world).pretty_C73D300_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakStrippedLog300VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakStrippedLog300VoxelVariantID;
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
