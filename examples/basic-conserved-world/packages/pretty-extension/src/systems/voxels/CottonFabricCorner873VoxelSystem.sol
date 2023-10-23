// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricCorner873VoxelID = bytes32(keccak256("cotton_fabric_corner_873"));
bytes32 constant CottonFabricCorner873VoxelVariantID = bytes32(keccak256("cotton_fabric_corner_873"));

contract CottonFabricCorner873VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricCorner873Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricCorner873VoxelVariantID, cottonFabricCorner873Variant);

    bytes32[] memory cottonFabricCorner873ChildVoxelTypes = new bytes32[](1);
    cottonFabricCorner873ChildVoxelTypes[0] = CottonFabricCorner873VoxelID;
    bytes32 baseVoxelTypeId = CottonFabricCorner873VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Corner873",
      CottonFabricCorner873VoxelID,
      baseVoxelTypeId,
      cottonFabricCorner873ChildVoxelTypes,
      cottonFabricCorner873ChildVoxelTypes,
      CottonFabricCorner873VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D873_enterWorld.selector,
        IWorld(world).pretty_C38D873_exitWorld.selector,
        IWorld(world).pretty_C38D873_variantSelector.selector,
        IWorld(world).pretty_C38D873_activate.selector,
        IWorld(world).pretty_C38D873_eventHandler.selector,
        IWorld(world).pretty_C38D873_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricCorner873VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricCorner873VoxelVariantID;
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
