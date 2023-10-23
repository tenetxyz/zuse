// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricStub1257PurpleVoxelID = bytes32(keccak256("cotton_fabric_stub_1257_purple"));
bytes32 constant CottonFabricStub1257PurpleVoxelVariantID = bytes32(keccak256("cotton_fabric_stub_1257_purple"));

contract CottonFabricStub1257PurpleVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricStub1257PurpleVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricStub1257PurpleVoxelVariantID, cottonFabricStub1257PurpleVariant);

    bytes32[] memory cottonFabricStub1257PurpleChildVoxelTypes = new bytes32[](1);
    cottonFabricStub1257PurpleChildVoxelTypes[0] = CottonFabricStub1257PurpleVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricStub1257PurpleVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Stub1257 Purple",
      CottonFabricStub1257PurpleVoxelID,
      baseVoxelTypeId,
      cottonFabricStub1257PurpleChildVoxelTypes,
      cottonFabricStub1257PurpleChildVoxelTypes,
      CottonFabricStub1257PurpleVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D1257E6_enterWorld.selector,
        IWorld(world).pretty_C38D1257E6_exitWorld.selector,
        IWorld(world).pretty_C38D1257E6_variantSelector.selector,
        IWorld(world).pretty_C38D1257E6_activate.selector,
        IWorld(world).pretty_C38D1257E6_eventHandler.selector,
        IWorld(world).pretty_C38D1257E6_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricStub1257PurpleVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricStub1257PurpleVoxelVariantID;
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
