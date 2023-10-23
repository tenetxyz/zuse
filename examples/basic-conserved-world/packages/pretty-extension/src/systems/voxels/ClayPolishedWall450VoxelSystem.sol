// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayPolishedWall450VoxelID = bytes32(keccak256("clay_polished_wall_450"));
bytes32 constant ClayPolishedWall450VoxelVariantID = bytes32(keccak256("clay_polished_wall_450"));

contract ClayPolishedWall450VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayPolishedWall450Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayPolishedWall450VoxelVariantID, clayPolishedWall450Variant);

    bytes32[] memory clayPolishedWall450ChildVoxelTypes = new bytes32[](1);
    clayPolishedWall450ChildVoxelTypes[0] = ClayPolishedWall450VoxelID;
    bytes32 baseVoxelTypeId = ClayPolishedWall450VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Polished Wall450",
      ClayPolishedWall450VoxelID,
      baseVoxelTypeId,
      clayPolishedWall450ChildVoxelTypes,
      clayPolishedWall450ChildVoxelTypes,
      ClayPolishedWall450VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C45D450_enterWorld.selector,
        IWorld(world).pretty_C45D450_exitWorld.selector,
        IWorld(world).pretty_C45D450_variantSelector.selector,
        IWorld(world).pretty_C45D450_activate.selector,
        IWorld(world).pretty_C45D450_eventHandler.selector,
        IWorld(world).pretty_C45D450_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayPolishedWall450VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayPolishedWall450VoxelVariantID;
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
