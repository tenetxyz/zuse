// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricSlab169BlueVoxelID = bytes32(keccak256("cotton_fabric_slab_169_blue"));
bytes32 constant CottonFabricSlab169BlueVoxelVariantID = bytes32(keccak256("cotton_fabric_slab_169_blue"));

contract CottonFabricSlab169BlueVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricSlab169BlueVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricSlab169BlueVoxelVariantID, cottonFabricSlab169BlueVariant);

    bytes32[] memory cottonFabricSlab169BlueChildVoxelTypes = new bytes32[](1);
    cottonFabricSlab169BlueChildVoxelTypes[0] = CottonFabricSlab169BlueVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricSlab169BlueVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Slab169 Blue",
      CottonFabricSlab169BlueVoxelID,
      baseVoxelTypeId,
      cottonFabricSlab169BlueChildVoxelTypes,
      cottonFabricSlab169BlueChildVoxelTypes,
      CottonFabricSlab169BlueVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D169E1_enterWorld.selector,
        IWorld(world).pretty_C38D169E1_exitWorld.selector,
        IWorld(world).pretty_C38D169E1_variantSelector.selector,
        IWorld(world).pretty_C38D169E1_activate.selector,
        IWorld(world).pretty_C38D169E1_eventHandler.selector,
        IWorld(world).pretty_C38D169E1_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricSlab169BlueVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricSlab169BlueVoxelVariantID;
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
