// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricSlice748PinkVoxelID = bytes32(keccak256("cotton_fabric_slice_748_pink"));
bytes32 constant CottonFabricSlice748PinkVoxelVariantID = bytes32(keccak256("cotton_fabric_slice_748_pink"));

contract CottonFabricSlice748PinkVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricSlice748PinkVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricSlice748PinkVoxelVariantID, cottonFabricSlice748PinkVariant);

    bytes32[] memory cottonFabricSlice748PinkChildVoxelTypes = new bytes32[](1);
    cottonFabricSlice748PinkChildVoxelTypes[0] = CottonFabricSlice748PinkVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricSlice748PinkVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Slice748 Pink",
      CottonFabricSlice748PinkVoxelID,
      baseVoxelTypeId,
      cottonFabricSlice748PinkChildVoxelTypes,
      cottonFabricSlice748PinkChildVoxelTypes,
      CottonFabricSlice748PinkVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D748E7_enterWorld.selector,
        IWorld(world).pretty_C38D748E7_exitWorld.selector,
        IWorld(world).pretty_C38D748E7_variantSelector.selector,
        IWorld(world).pretty_C38D748E7_activate.selector,
        IWorld(world).pretty_C38D748E7_eventHandler.selector,
        IWorld(world).pretty_C38D748E7_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricSlice748PinkVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricSlice748PinkVoxelVariantID;
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
