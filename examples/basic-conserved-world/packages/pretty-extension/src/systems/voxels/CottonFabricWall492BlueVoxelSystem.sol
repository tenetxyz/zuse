// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricWall492BlueVoxelID = bytes32(keccak256("cotton_fabric_wall_492_blue"));
bytes32 constant CottonFabricWall492BlueVoxelVariantID = bytes32(keccak256("cotton_fabric_wall_492_blue"));

contract CottonFabricWall492BlueVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricWall492BlueVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricWall492BlueVoxelVariantID, cottonFabricWall492BlueVariant);

    bytes32[] memory cottonFabricWall492BlueChildVoxelTypes = new bytes32[](1);
    cottonFabricWall492BlueChildVoxelTypes[0] = CottonFabricWall492BlueVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricWall492BlueVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Wall492 Blue",
      CottonFabricWall492BlueVoxelID,
      baseVoxelTypeId,
      cottonFabricWall492BlueChildVoxelTypes,
      cottonFabricWall492BlueChildVoxelTypes,
      CottonFabricWall492BlueVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D492E1_enterWorld.selector,
        IWorld(world).pretty_C38D492E1_exitWorld.selector,
        IWorld(world).pretty_C38D492E1_variantSelector.selector,
        IWorld(world).pretty_C38D492E1_activate.selector,
        IWorld(world).pretty_C38D492E1_eventHandler.selector,
        IWorld(world).pretty_C38D492E1_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricWall492BlueVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricWall492BlueVoxelVariantID;
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
