// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricStep194BlueVoxelID = bytes32(keccak256("cotton_fabric_step_194_blue"));
bytes32 constant CottonFabricStep194BlueVoxelVariantID = bytes32(keccak256("cotton_fabric_step_194_blue"));

contract CottonFabricStep194BlueVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricStep194BlueVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricStep194BlueVoxelVariantID, cottonFabricStep194BlueVariant);

    bytes32[] memory cottonFabricStep194BlueChildVoxelTypes = new bytes32[](1);
    cottonFabricStep194BlueChildVoxelTypes[0] = CottonFabricStep194BlueVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricStep194BlueVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Step194 Blue",
      CottonFabricStep194BlueVoxelID,
      baseVoxelTypeId,
      cottonFabricStep194BlueChildVoxelTypes,
      cottonFabricStep194BlueChildVoxelTypes,
      CottonFabricStep194BlueVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D194E1_enterWorld.selector,
        IWorld(world).pretty_C38D194E1_exitWorld.selector,
        IWorld(world).pretty_C38D194E1_variantSelector.selector,
        IWorld(world).pretty_C38D194E1_activate.selector,
        IWorld(world).pretty_C38D194E1_eventHandler.selector,
        IWorld(world).pretty_C38D194E1_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricStep194BlueVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricStep194BlueVoxelVariantID;
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
