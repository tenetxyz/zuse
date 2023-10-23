// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricWall492BlackVoxelID = bytes32(keccak256("cotton_fabric_wall_492_black"));
bytes32 constant CottonFabricWall492BlackVoxelVariantID = bytes32(keccak256("cotton_fabric_wall_492_black"));

contract CottonFabricWall492BlackVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricWall492BlackVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricWall492BlackVoxelVariantID, cottonFabricWall492BlackVariant);

    bytes32[] memory cottonFabricWall492BlackChildVoxelTypes = new bytes32[](1);
    cottonFabricWall492BlackChildVoxelTypes[0] = CottonFabricWall492BlackVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricWall492BlackVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Wall492 Black",
      CottonFabricWall492BlackVoxelID,
      baseVoxelTypeId,
      cottonFabricWall492BlackChildVoxelTypes,
      cottonFabricWall492BlackChildVoxelTypes,
      CottonFabricWall492BlackVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D492E9_enterWorld.selector,
        IWorld(world).pretty_C38D492E9_exitWorld.selector,
        IWorld(world).pretty_C38D492E9_variantSelector.selector,
        IWorld(world).pretty_C38D492E9_activate.selector,
        IWorld(world).pretty_C38D492E9_eventHandler.selector,
        IWorld(world).pretty_C38D492E9_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricWall492BlackVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricWall492BlackVoxelVariantID;
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
