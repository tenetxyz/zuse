// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant StoneFence364VoxelID = bytes32(keccak256("stone_fence_364"));
bytes32 constant StoneFence364VoxelVariantID = bytes32(keccak256("stone_fence_364"));

contract StoneFence364VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory stoneFence364Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, StoneFence364VoxelVariantID, stoneFence364Variant);

    bytes32[] memory stoneFence364ChildVoxelTypes = new bytes32[](1);
    stoneFence364ChildVoxelTypes[0] = StoneFence364VoxelID;
    bytes32 baseVoxelTypeId = StoneFence364VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Stone Fence364",
      StoneFence364VoxelID,
      baseVoxelTypeId,
      stoneFence364ChildVoxelTypes,
      stoneFence364ChildVoxelTypes,
      StoneFence364VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C4D364_enterWorld.selector,
        IWorld(world).pretty_C4D364_exitWorld.selector,
        IWorld(world).pretty_C4D364_variantSelector.selector,
        IWorld(world).pretty_C4D364_activate.selector,
        IWorld(world).pretty_C4D364_eventHandler.selector,
        IWorld(world).pretty_C4D364_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, StoneFence364VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return StoneFence364VoxelVariantID;
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
