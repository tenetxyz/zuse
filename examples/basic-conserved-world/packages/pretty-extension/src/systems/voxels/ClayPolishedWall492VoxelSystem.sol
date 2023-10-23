// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayPolishedWall492VoxelID = bytes32(keccak256("clay_polished_wall_492"));
bytes32 constant ClayPolishedWall492VoxelVariantID = bytes32(keccak256("clay_polished_wall_492"));

contract ClayPolishedWall492VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayPolishedWall492Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayPolishedWall492VoxelVariantID, clayPolishedWall492Variant);

    bytes32[] memory clayPolishedWall492ChildVoxelTypes = new bytes32[](1);
    clayPolishedWall492ChildVoxelTypes[0] = ClayPolishedWall492VoxelID;
    bytes32 baseVoxelTypeId = ClayPolishedWall492VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Polished Wall492",
      ClayPolishedWall492VoxelID,
      baseVoxelTypeId,
      clayPolishedWall492ChildVoxelTypes,
      clayPolishedWall492ChildVoxelTypes,
      ClayPolishedWall492VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C45D492_enterWorld.selector,
        IWorld(world).pretty_C45D492_exitWorld.selector,
        IWorld(world).pretty_C45D492_variantSelector.selector,
        IWorld(world).pretty_C45D492_activate.selector,
        IWorld(world).pretty_C45D492_eventHandler.selector,
        IWorld(world).pretty_C45D492_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayPolishedWall492VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayPolishedWall492VoxelVariantID;
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
