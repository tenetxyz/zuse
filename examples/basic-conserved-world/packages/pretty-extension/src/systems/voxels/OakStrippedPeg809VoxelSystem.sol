// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakStrippedPeg809VoxelID = bytes32(keccak256("oak_stripped_peg_809"));
bytes32 constant OakStrippedPeg809VoxelVariantID = bytes32(keccak256("oak_stripped_peg_809"));

contract OakStrippedPeg809VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakStrippedPeg809Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakStrippedPeg809VoxelVariantID, oakStrippedPeg809Variant);

    bytes32[] memory oakStrippedPeg809ChildVoxelTypes = new bytes32[](1);
    oakStrippedPeg809ChildVoxelTypes[0] = OakStrippedPeg809VoxelID;
    bytes32 baseVoxelTypeId = OakStrippedPeg809VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Stripped Peg809",
      OakStrippedPeg809VoxelID,
      baseVoxelTypeId,
      oakStrippedPeg809ChildVoxelTypes,
      oakStrippedPeg809ChildVoxelTypes,
      OakStrippedPeg809VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C73D809_enterWorld.selector,
        IWorld(world).pretty_C73D809_exitWorld.selector,
        IWorld(world).pretty_C73D809_variantSelector.selector,
        IWorld(world).pretty_C73D809_activate.selector,
        IWorld(world).pretty_C73D809_eventHandler.selector,
        IWorld(world).pretty_C73D809_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakStrippedPeg809VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakStrippedPeg809VoxelVariantID;
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
