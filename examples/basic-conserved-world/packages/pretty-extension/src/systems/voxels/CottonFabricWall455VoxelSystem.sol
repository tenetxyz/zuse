// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricWall455VoxelID = bytes32(keccak256("cotton_fabric_wall_455"));
bytes32 constant CottonFabricWall455VoxelVariantID = bytes32(keccak256("cotton_fabric_wall_455"));

contract CottonFabricWall455VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricWall455Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricWall455VoxelVariantID, cottonFabricWall455Variant);

    bytes32[] memory cottonFabricWall455ChildVoxelTypes = new bytes32[](1);
    cottonFabricWall455ChildVoxelTypes[0] = CottonFabricWall455VoxelID;
    bytes32 baseVoxelTypeId = CottonFabricWall455VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Wall455",
      CottonFabricWall455VoxelID,
      baseVoxelTypeId,
      cottonFabricWall455ChildVoxelTypes,
      cottonFabricWall455ChildVoxelTypes,
      CottonFabricWall455VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D455_enterWorld.selector,
        IWorld(world).pretty_C38D455_exitWorld.selector,
        IWorld(world).pretty_C38D455_variantSelector.selector,
        IWorld(world).pretty_C38D455_activate.selector,
        IWorld(world).pretty_C38D455_eventHandler.selector,
        IWorld(world).pretty_C38D455_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricWall455VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricWall455VoxelVariantID;
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
