// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricBrightpinkVoxelID = bytes32(keccak256("cotton_fabric_brightpink"));
bytes32 constant CottonFabricBrightpinkVoxelVariantID = bytes32(keccak256("cotton_fabric_brightpink"));

contract CottonFabricBrightpinkVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricBrightpinkVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricBrightpinkVoxelVariantID, cottonFabricBrightpinkVariant);

    bytes32[] memory cottonFabricBrightpinkChildVoxelTypes = new bytes32[](1);
    cottonFabricBrightpinkChildVoxelTypes[0] = CottonFabricBrightpinkVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricBrightpinkVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Brightpink",
      CottonFabricBrightpinkVoxelID,
      baseVoxelTypeId,
      cottonFabricBrightpinkChildVoxelTypes,
      cottonFabricBrightpinkChildVoxelTypes,
      CottonFabricBrightpinkVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38E18_enterWorld.selector,
        IWorld(world).pretty_C38E18_exitWorld.selector,
        IWorld(world).pretty_C38E18_variantSelector.selector,
        IWorld(world).pretty_C38E18_activate.selector,
        IWorld(world).pretty_C38E18_eventHandler.selector,
        IWorld(world).pretty_C38E18_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricBrightpinkVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricBrightpinkVoxelVariantID;
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
