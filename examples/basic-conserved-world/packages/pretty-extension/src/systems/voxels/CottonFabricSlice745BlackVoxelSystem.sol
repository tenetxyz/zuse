// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricSlice745BlackVoxelID = bytes32(keccak256("cotton_fabric_slice_745_black"));
bytes32 constant CottonFabricSlice745BlackVoxelVariantID = bytes32(keccak256("cotton_fabric_slice_745_black"));

contract CottonFabricSlice745BlackVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricSlice745BlackVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricSlice745BlackVoxelVariantID, cottonFabricSlice745BlackVariant);

    bytes32[] memory cottonFabricSlice745BlackChildVoxelTypes = new bytes32[](1);
    cottonFabricSlice745BlackChildVoxelTypes[0] = CottonFabricSlice745BlackVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricSlice745BlackVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Slice745 Black",
      CottonFabricSlice745BlackVoxelID,
      baseVoxelTypeId,
      cottonFabricSlice745BlackChildVoxelTypes,
      cottonFabricSlice745BlackChildVoxelTypes,
      CottonFabricSlice745BlackVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D745E9_enterWorld.selector,
        IWorld(world).pretty_C38D745E9_exitWorld.selector,
        IWorld(world).pretty_C38D745E9_variantSelector.selector,
        IWorld(world).pretty_C38D745E9_activate.selector,
        IWorld(world).pretty_C38D745E9_eventHandler.selector,
        IWorld(world).pretty_C38D745E9_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricSlice745BlackVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricSlice745BlackVoxelVariantID;
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
