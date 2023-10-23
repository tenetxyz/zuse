// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricCorner834VoxelID = bytes32(keccak256("cotton_fabric_corner_834"));
bytes32 constant CottonFabricCorner834VoxelVariantID = bytes32(keccak256("cotton_fabric_corner_834"));

contract CottonFabricCorner834VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricCorner834Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricCorner834VoxelVariantID, cottonFabricCorner834Variant);

    bytes32[] memory cottonFabricCorner834ChildVoxelTypes = new bytes32[](1);
    cottonFabricCorner834ChildVoxelTypes[0] = CottonFabricCorner834VoxelID;
    bytes32 baseVoxelTypeId = CottonFabricCorner834VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Corner834",
      CottonFabricCorner834VoxelID,
      baseVoxelTypeId,
      cottonFabricCorner834ChildVoxelTypes,
      cottonFabricCorner834ChildVoxelTypes,
      CottonFabricCorner834VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D834_enterWorld.selector,
        IWorld(world).pretty_C38D834_exitWorld.selector,
        IWorld(world).pretty_C38D834_variantSelector.selector,
        IWorld(world).pretty_C38D834_activate.selector,
        IWorld(world).pretty_C38D834_eventHandler.selector,
        IWorld(world).pretty_C38D834_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricCorner834VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricCorner834VoxelVariantID;
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
