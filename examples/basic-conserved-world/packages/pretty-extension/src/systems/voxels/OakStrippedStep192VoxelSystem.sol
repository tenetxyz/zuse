// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakStrippedStep192VoxelID = bytes32(keccak256("oak_stripped_step_192"));
bytes32 constant OakStrippedStep192VoxelVariantID = bytes32(keccak256("oak_stripped_step_192"));

contract OakStrippedStep192VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakStrippedStep192Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakStrippedStep192VoxelVariantID, oakStrippedStep192Variant);

    bytes32[] memory oakStrippedStep192ChildVoxelTypes = new bytes32[](1);
    oakStrippedStep192ChildVoxelTypes[0] = OakStrippedStep192VoxelID;
    bytes32 baseVoxelTypeId = OakStrippedStep192VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Stripped Step192",
      OakStrippedStep192VoxelID,
      baseVoxelTypeId,
      oakStrippedStep192ChildVoxelTypes,
      oakStrippedStep192ChildVoxelTypes,
      OakStrippedStep192VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C73D192_enterWorld.selector,
        IWorld(world).pretty_C73D192_exitWorld.selector,
        IWorld(world).pretty_C73D192_variantSelector.selector,
        IWorld(world).pretty_C73D192_activate.selector,
        IWorld(world).pretty_C73D192_eventHandler.selector,
        IWorld(world).pretty_C73D192_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakStrippedStep192VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakStrippedStep192VoxelVariantID;
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
