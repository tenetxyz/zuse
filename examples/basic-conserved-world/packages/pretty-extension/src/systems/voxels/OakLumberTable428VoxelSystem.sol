// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberTable428VoxelID = bytes32(keccak256("oak_lumber_table_428"));
bytes32 constant OakLumberTable428VoxelVariantID = bytes32(keccak256("oak_lumber_table_428"));

contract OakLumberTable428VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberTable428Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberTable428VoxelVariantID, oakLumberTable428Variant);

    bytes32[] memory oakLumberTable428ChildVoxelTypes = new bytes32[](1);
    oakLumberTable428ChildVoxelTypes[0] = OakLumberTable428VoxelID;
    bytes32 baseVoxelTypeId = OakLumberTable428VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Table428",
      OakLumberTable428VoxelID,
      baseVoxelTypeId,
      oakLumberTable428ChildVoxelTypes,
      oakLumberTable428ChildVoxelTypes,
      OakLumberTable428VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D428_enterWorld.selector,
        IWorld(world).pretty_C31D428_exitWorld.selector,
        IWorld(world).pretty_C31D428_variantSelector.selector,
        IWorld(world).pretty_C31D428_activate.selector,
        IWorld(world).pretty_C31D428_eventHandler.selector,
        IWorld(world).pretty_C31D428_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberTable428VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberTable428VoxelVariantID;
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
