// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BirchStrippedWall448VoxelID = bytes32(keccak256("birch_stripped_wall_448"));
bytes32 constant BirchStrippedWall448VoxelVariantID = bytes32(keccak256("birch_stripped_wall_448"));

contract BirchStrippedWall448VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory birchStrippedWall448Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BirchStrippedWall448VoxelVariantID, birchStrippedWall448Variant);

    bytes32[] memory birchStrippedWall448ChildVoxelTypes = new bytes32[](1);
    birchStrippedWall448ChildVoxelTypes[0] = BirchStrippedWall448VoxelID;
    bytes32 baseVoxelTypeId = BirchStrippedWall448VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Birch Stripped Wall448",
      BirchStrippedWall448VoxelID,
      baseVoxelTypeId,
      birchStrippedWall448ChildVoxelTypes,
      birchStrippedWall448ChildVoxelTypes,
      BirchStrippedWall448VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C71D448_enterWorld.selector,
        IWorld(world).pretty_C71D448_exitWorld.selector,
        IWorld(world).pretty_C71D448_variantSelector.selector,
        IWorld(world).pretty_C71D448_activate.selector,
        IWorld(world).pretty_C71D448_eventHandler.selector,
        IWorld(world).pretty_C71D448_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BirchStrippedWall448VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BirchStrippedWall448VoxelVariantID;
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
