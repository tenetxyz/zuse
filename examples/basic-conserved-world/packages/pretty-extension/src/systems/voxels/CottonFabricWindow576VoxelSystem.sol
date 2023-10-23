// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricWindow576VoxelID = bytes32(keccak256("cotton_fabric_window_576"));
bytes32 constant CottonFabricWindow576VoxelVariantID = bytes32(keccak256("cotton_fabric_window_576"));

contract CottonFabricWindow576VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricWindow576Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricWindow576VoxelVariantID, cottonFabricWindow576Variant);

    bytes32[] memory cottonFabricWindow576ChildVoxelTypes = new bytes32[](1);
    cottonFabricWindow576ChildVoxelTypes[0] = CottonFabricWindow576VoxelID;
    bytes32 baseVoxelTypeId = CottonFabricWindow576VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Window576",
      CottonFabricWindow576VoxelID,
      baseVoxelTypeId,
      cottonFabricWindow576ChildVoxelTypes,
      cottonFabricWindow576ChildVoxelTypes,
      CottonFabricWindow576VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D576_enterWorld.selector,
        IWorld(world).pretty_C38D576_exitWorld.selector,
        IWorld(world).pretty_C38D576_variantSelector.selector,
        IWorld(world).pretty_C38D576_activate.selector,
        IWorld(world).pretty_C38D576_eventHandler.selector,
        IWorld(world).pretty_C38D576_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricWindow576VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricWindow576VoxelVariantID;
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
