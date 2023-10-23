// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakStrippedStep197VoxelID = bytes32(keccak256("oak_stripped_step_197"));
bytes32 constant OakStrippedStep197VoxelVariantID = bytes32(keccak256("oak_stripped_step_197"));

contract OakStrippedStep197VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakStrippedStep197Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakStrippedStep197VoxelVariantID, oakStrippedStep197Variant);

    bytes32[] memory oakStrippedStep197ChildVoxelTypes = new bytes32[](1);
    oakStrippedStep197ChildVoxelTypes[0] = OakStrippedStep197VoxelID;
    bytes32 baseVoxelTypeId = OakStrippedStep197VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Stripped Step197",
      OakStrippedStep197VoxelID,
      baseVoxelTypeId,
      oakStrippedStep197ChildVoxelTypes,
      oakStrippedStep197ChildVoxelTypes,
      OakStrippedStep197VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C73D197_enterWorld.selector,
        IWorld(world).pretty_C73D197_exitWorld.selector,
        IWorld(world).pretty_C73D197_variantSelector.selector,
        IWorld(world).pretty_C73D197_activate.selector,
        IWorld(world).pretty_C73D197_eventHandler.selector,
        IWorld(world).pretty_C73D197_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakStrippedStep197VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakStrippedStep197VoxelVariantID;
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
