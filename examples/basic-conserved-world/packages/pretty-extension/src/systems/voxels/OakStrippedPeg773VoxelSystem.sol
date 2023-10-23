// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakStrippedPeg773VoxelID = bytes32(keccak256("oak_stripped_peg_773"));
bytes32 constant OakStrippedPeg773VoxelVariantID = bytes32(keccak256("oak_stripped_peg_773"));

contract OakStrippedPeg773VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakStrippedPeg773Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakStrippedPeg773VoxelVariantID, oakStrippedPeg773Variant);

    bytes32[] memory oakStrippedPeg773ChildVoxelTypes = new bytes32[](1);
    oakStrippedPeg773ChildVoxelTypes[0] = OakStrippedPeg773VoxelID;
    bytes32 baseVoxelTypeId = OakStrippedPeg773VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Stripped Peg773",
      OakStrippedPeg773VoxelID,
      baseVoxelTypeId,
      oakStrippedPeg773ChildVoxelTypes,
      oakStrippedPeg773ChildVoxelTypes,
      OakStrippedPeg773VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C73D773_enterWorld.selector,
        IWorld(world).pretty_C73D773_exitWorld.selector,
        IWorld(world).pretty_C73D773_variantSelector.selector,
        IWorld(world).pretty_C73D773_activate.selector,
        IWorld(world).pretty_C73D773_eventHandler.selector,
        IWorld(world).pretty_C73D773_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakStrippedPeg773VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakStrippedPeg773VoxelVariantID;
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
