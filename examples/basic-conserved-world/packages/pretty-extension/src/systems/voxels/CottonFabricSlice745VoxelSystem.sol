// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricSlice745VoxelID = bytes32(keccak256("cotton_fabric_slice_745"));
bytes32 constant CottonFabricSlice745VoxelVariantID = bytes32(keccak256("cotton_fabric_slice_745"));

contract CottonFabricSlice745VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricSlice745Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricSlice745VoxelVariantID, cottonFabricSlice745Variant);

    bytes32[] memory cottonFabricSlice745ChildVoxelTypes = new bytes32[](1);
    cottonFabricSlice745ChildVoxelTypes[0] = CottonFabricSlice745VoxelID;
    bytes32 baseVoxelTypeId = CottonFabricSlice745VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Slice745",
      CottonFabricSlice745VoxelID,
      baseVoxelTypeId,
      cottonFabricSlice745ChildVoxelTypes,
      cottonFabricSlice745ChildVoxelTypes,
      CottonFabricSlice745VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D745_enterWorld.selector,
        IWorld(world).pretty_C38D745_exitWorld.selector,
        IWorld(world).pretty_C38D745_variantSelector.selector,
        IWorld(world).pretty_C38D745_activate.selector,
        IWorld(world).pretty_C38D745_eventHandler.selector,
        IWorld(world).pretty_C38D745_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricSlice745VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricSlice745VoxelVariantID;
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
