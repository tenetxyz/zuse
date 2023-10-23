// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakStrippedCorner837VoxelID = bytes32(keccak256("oak_stripped_corner_837"));
bytes32 constant OakStrippedCorner837VoxelVariantID = bytes32(keccak256("oak_stripped_corner_837"));

contract OakStrippedCorner837VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakStrippedCorner837Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakStrippedCorner837VoxelVariantID, oakStrippedCorner837Variant);

    bytes32[] memory oakStrippedCorner837ChildVoxelTypes = new bytes32[](1);
    oakStrippedCorner837ChildVoxelTypes[0] = OakStrippedCorner837VoxelID;
    bytes32 baseVoxelTypeId = OakStrippedCorner837VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Stripped Corner837",
      OakStrippedCorner837VoxelID,
      baseVoxelTypeId,
      oakStrippedCorner837ChildVoxelTypes,
      oakStrippedCorner837ChildVoxelTypes,
      OakStrippedCorner837VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C73D837_enterWorld.selector,
        IWorld(world).pretty_C73D837_exitWorld.selector,
        IWorld(world).pretty_C73D837_variantSelector.selector,
        IWorld(world).pretty_C73D837_activate.selector,
        IWorld(world).pretty_C73D837_eventHandler.selector,
        IWorld(world).pretty_C73D837_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakStrippedCorner837VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakStrippedCorner837VoxelVariantID;
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
