// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricOutset1157BlueVoxelID = bytes32(keccak256("cotton_fabric_outset_1157_blue"));
bytes32 constant CottonFabricOutset1157BlueVoxelVariantID = bytes32(keccak256("cotton_fabric_outset_1157_blue"));

contract CottonFabricOutset1157BlueVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricOutset1157BlueVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricOutset1157BlueVoxelVariantID, cottonFabricOutset1157BlueVariant);

    bytes32[] memory cottonFabricOutset1157BlueChildVoxelTypes = new bytes32[](1);
    cottonFabricOutset1157BlueChildVoxelTypes[0] = CottonFabricOutset1157BlueVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricOutset1157BlueVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Outset1157 Blue",
      CottonFabricOutset1157BlueVoxelID,
      baseVoxelTypeId,
      cottonFabricOutset1157BlueChildVoxelTypes,
      cottonFabricOutset1157BlueChildVoxelTypes,
      CottonFabricOutset1157BlueVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D1157E1_enterWorld.selector,
        IWorld(world).pretty_C38D1157E1_exitWorld.selector,
        IWorld(world).pretty_C38D1157E1_variantSelector.selector,
        IWorld(world).pretty_C38D1157E1_activate.selector,
        IWorld(world).pretty_C38D1157E1_eventHandler.selector,
        IWorld(world).pretty_C38D1157E1_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricOutset1157BlueVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricOutset1157BlueVoxelVariantID;
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
