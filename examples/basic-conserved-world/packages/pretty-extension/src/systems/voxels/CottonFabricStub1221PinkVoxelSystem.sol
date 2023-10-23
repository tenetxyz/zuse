// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricStub1221PinkVoxelID = bytes32(keccak256("cotton_fabric_stub_1221_pink"));
bytes32 constant CottonFabricStub1221PinkVoxelVariantID = bytes32(keccak256("cotton_fabric_stub_1221_pink"));

contract CottonFabricStub1221PinkVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricStub1221PinkVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricStub1221PinkVoxelVariantID, cottonFabricStub1221PinkVariant);

    bytes32[] memory cottonFabricStub1221PinkChildVoxelTypes = new bytes32[](1);
    cottonFabricStub1221PinkChildVoxelTypes[0] = CottonFabricStub1221PinkVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricStub1221PinkVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Stub1221 Pink",
      CottonFabricStub1221PinkVoxelID,
      baseVoxelTypeId,
      cottonFabricStub1221PinkChildVoxelTypes,
      cottonFabricStub1221PinkChildVoxelTypes,
      CottonFabricStub1221PinkVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D1221E7_enterWorld.selector,
        IWorld(world).pretty_C38D1221E7_exitWorld.selector,
        IWorld(world).pretty_C38D1221E7_variantSelector.selector,
        IWorld(world).pretty_C38D1221E7_activate.selector,
        IWorld(world).pretty_C38D1221E7_eventHandler.selector,
        IWorld(world).pretty_C38D1221E7_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricStub1221PinkVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricStub1221PinkVoxelVariantID;
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
