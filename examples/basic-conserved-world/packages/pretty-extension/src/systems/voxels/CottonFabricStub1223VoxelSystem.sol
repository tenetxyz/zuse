// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricStub1223VoxelID = bytes32(keccak256("cotton_fabric_stub_1223"));
bytes32 constant CottonFabricStub1223VoxelVariantID = bytes32(keccak256("cotton_fabric_stub_1223"));

contract CottonFabricStub1223VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricStub1223Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricStub1223VoxelVariantID, cottonFabricStub1223Variant);

    bytes32[] memory cottonFabricStub1223ChildVoxelTypes = new bytes32[](1);
    cottonFabricStub1223ChildVoxelTypes[0] = CottonFabricStub1223VoxelID;
    bytes32 baseVoxelTypeId = CottonFabricStub1223VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Stub1223",
      CottonFabricStub1223VoxelID,
      baseVoxelTypeId,
      cottonFabricStub1223ChildVoxelTypes,
      cottonFabricStub1223ChildVoxelTypes,
      CottonFabricStub1223VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D1223_enterWorld.selector,
        IWorld(world).pretty_C38D1223_exitWorld.selector,
        IWorld(world).pretty_C38D1223_variantSelector.selector,
        IWorld(world).pretty_C38D1223_activate.selector,
        IWorld(world).pretty_C38D1223_eventHandler.selector,
        IWorld(world).pretty_C38D1223_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricStub1223VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricStub1223VoxelVariantID;
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
