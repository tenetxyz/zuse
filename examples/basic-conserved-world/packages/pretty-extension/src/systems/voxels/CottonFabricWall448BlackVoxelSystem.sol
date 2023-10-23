// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricWall448BlackVoxelID = bytes32(keccak256("cotton_fabric_wall_448_black"));
bytes32 constant CottonFabricWall448BlackVoxelVariantID = bytes32(keccak256("cotton_fabric_wall_448_black"));

contract CottonFabricWall448BlackVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricWall448BlackVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricWall448BlackVoxelVariantID, cottonFabricWall448BlackVariant);

    bytes32[] memory cottonFabricWall448BlackChildVoxelTypes = new bytes32[](1);
    cottonFabricWall448BlackChildVoxelTypes[0] = CottonFabricWall448BlackVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricWall448BlackVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Wall448 Black",
      CottonFabricWall448BlackVoxelID,
      baseVoxelTypeId,
      cottonFabricWall448BlackChildVoxelTypes,
      cottonFabricWall448BlackChildVoxelTypes,
      CottonFabricWall448BlackVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D448E9_enterWorld.selector,
        IWorld(world).pretty_C38D448E9_exitWorld.selector,
        IWorld(world).pretty_C38D448E9_variantSelector.selector,
        IWorld(world).pretty_C38D448E9_activate.selector,
        IWorld(world).pretty_C38D448E9_eventHandler.selector,
        IWorld(world).pretty_C38D448E9_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricWall448BlackVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricWall448BlackVoxelVariantID;
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
