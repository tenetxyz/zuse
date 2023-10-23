// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricOutset1157PinkVoxelID = bytes32(keccak256("cotton_fabric_outset_1157_pink"));
bytes32 constant CottonFabricOutset1157PinkVoxelVariantID = bytes32(keccak256("cotton_fabric_outset_1157_pink"));

contract CottonFabricOutset1157PinkVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricOutset1157PinkVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricOutset1157PinkVoxelVariantID, cottonFabricOutset1157PinkVariant);

    bytes32[] memory cottonFabricOutset1157PinkChildVoxelTypes = new bytes32[](1);
    cottonFabricOutset1157PinkChildVoxelTypes[0] = CottonFabricOutset1157PinkVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricOutset1157PinkVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Outset1157 Pink",
      CottonFabricOutset1157PinkVoxelID,
      baseVoxelTypeId,
      cottonFabricOutset1157PinkChildVoxelTypes,
      cottonFabricOutset1157PinkChildVoxelTypes,
      CottonFabricOutset1157PinkVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D1157E7_enterWorld.selector,
        IWorld(world).pretty_C38D1157E7_exitWorld.selector,
        IWorld(world).pretty_C38D1157E7_variantSelector.selector,
        IWorld(world).pretty_C38D1157E7_activate.selector,
        IWorld(world).pretty_C38D1157E7_eventHandler.selector,
        IWorld(world).pretty_C38D1157E7_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricOutset1157PinkVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricOutset1157PinkVoxelVariantID;
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
