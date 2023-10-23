// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricOutset1196PurpleVoxelID = bytes32(keccak256("cotton_fabric_outset_1196_purple"));
bytes32 constant CottonFabricOutset1196PurpleVoxelVariantID = bytes32(keccak256("cotton_fabric_outset_1196_purple"));

contract CottonFabricOutset1196PurpleVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricOutset1196PurpleVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricOutset1196PurpleVoxelVariantID, cottonFabricOutset1196PurpleVariant);

    bytes32[] memory cottonFabricOutset1196PurpleChildVoxelTypes = new bytes32[](1);
    cottonFabricOutset1196PurpleChildVoxelTypes[0] = CottonFabricOutset1196PurpleVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricOutset1196PurpleVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Outset1196 Purple",
      CottonFabricOutset1196PurpleVoxelID,
      baseVoxelTypeId,
      cottonFabricOutset1196PurpleChildVoxelTypes,
      cottonFabricOutset1196PurpleChildVoxelTypes,
      CottonFabricOutset1196PurpleVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D1196E6_enterWorld.selector,
        IWorld(world).pretty_C38D1196E6_exitWorld.selector,
        IWorld(world).pretty_C38D1196E6_variantSelector.selector,
        IWorld(world).pretty_C38D1196E6_activate.selector,
        IWorld(world).pretty_C38D1196E6_eventHandler.selector,
        IWorld(world).pretty_C38D1196E6_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricOutset1196PurpleVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricOutset1196PurpleVoxelVariantID;
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
