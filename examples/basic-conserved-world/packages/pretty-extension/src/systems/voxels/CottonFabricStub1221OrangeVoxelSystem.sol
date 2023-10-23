// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricStub1221OrangeVoxelID = bytes32(keccak256("cotton_fabric_stub_1221_orange"));
bytes32 constant CottonFabricStub1221OrangeVoxelVariantID = bytes32(keccak256("cotton_fabric_stub_1221_orange"));

contract CottonFabricStub1221OrangeVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricStub1221OrangeVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricStub1221OrangeVoxelVariantID, cottonFabricStub1221OrangeVariant);

    bytes32[] memory cottonFabricStub1221OrangeChildVoxelTypes = new bytes32[](1);
    cottonFabricStub1221OrangeChildVoxelTypes[0] = CottonFabricStub1221OrangeVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricStub1221OrangeVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Stub1221 Orange",
      CottonFabricStub1221OrangeVoxelID,
      baseVoxelTypeId,
      cottonFabricStub1221OrangeChildVoxelTypes,
      cottonFabricStub1221OrangeChildVoxelTypes,
      CottonFabricStub1221OrangeVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D1221E4_enterWorld.selector,
        IWorld(world).pretty_C38D1221E4_exitWorld.selector,
        IWorld(world).pretty_C38D1221E4_variantSelector.selector,
        IWorld(world).pretty_C38D1221E4_activate.selector,
        IWorld(world).pretty_C38D1221E4_eventHandler.selector,
        IWorld(world).pretty_C38D1221E4_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricStub1221OrangeVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricStub1221OrangeVoxelVariantID;
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
