// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricWall453VoxelID = bytes32(keccak256("cotton_fabric_wall_453"));
bytes32 constant CottonFabricWall453VoxelVariantID = bytes32(keccak256("cotton_fabric_wall_453"));

contract CottonFabricWall453VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricWall453Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricWall453VoxelVariantID, cottonFabricWall453Variant);

    bytes32[] memory cottonFabricWall453ChildVoxelTypes = new bytes32[](1);
    cottonFabricWall453ChildVoxelTypes[0] = CottonFabricWall453VoxelID;
    bytes32 baseVoxelTypeId = CottonFabricWall453VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Wall453",
      CottonFabricWall453VoxelID,
      baseVoxelTypeId,
      cottonFabricWall453ChildVoxelTypes,
      cottonFabricWall453ChildVoxelTypes,
      CottonFabricWall453VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D453_enterWorld.selector,
        IWorld(world).pretty_C38D453_exitWorld.selector,
        IWorld(world).pretty_C38D453_variantSelector.selector,
        IWorld(world).pretty_C38D453_activate.selector,
        IWorld(world).pretty_C38D453_eventHandler.selector,
        IWorld(world).pretty_C38D453_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricWall453VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricWall453VoxelVariantID;
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
