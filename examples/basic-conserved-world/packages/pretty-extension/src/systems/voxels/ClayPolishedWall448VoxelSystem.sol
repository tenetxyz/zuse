// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayPolishedWall448VoxelID = bytes32(keccak256("clay_polished_wall_448"));
bytes32 constant ClayPolishedWall448VoxelVariantID = bytes32(keccak256("clay_polished_wall_448"));

contract ClayPolishedWall448VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayPolishedWall448Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayPolishedWall448VoxelVariantID, clayPolishedWall448Variant);

    bytes32[] memory clayPolishedWall448ChildVoxelTypes = new bytes32[](1);
    clayPolishedWall448ChildVoxelTypes[0] = ClayPolishedWall448VoxelID;
    bytes32 baseVoxelTypeId = ClayPolishedWall448VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Polished Wall448",
      ClayPolishedWall448VoxelID,
      baseVoxelTypeId,
      clayPolishedWall448ChildVoxelTypes,
      clayPolishedWall448ChildVoxelTypes,
      ClayPolishedWall448VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C45D448_enterWorld.selector,
        IWorld(world).pretty_C45D448_exitWorld.selector,
        IWorld(world).pretty_C45D448_variantSelector.selector,
        IWorld(world).pretty_C45D448_activate.selector,
        IWorld(world).pretty_C45D448_eventHandler.selector,
        IWorld(world).pretty_C45D448_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayPolishedWall448VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayPolishedWall448VoxelVariantID;
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
