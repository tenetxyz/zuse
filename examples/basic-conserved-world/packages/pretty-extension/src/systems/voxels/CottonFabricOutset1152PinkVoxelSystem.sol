// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricOutset1152PinkVoxelID = bytes32(keccak256("cotton_fabric_outset_1152_pink"));
bytes32 constant CottonFabricOutset1152PinkVoxelVariantID = bytes32(keccak256("cotton_fabric_outset_1152_pink"));

contract CottonFabricOutset1152PinkVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricOutset1152PinkVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricOutset1152PinkVoxelVariantID, cottonFabricOutset1152PinkVariant);

    bytes32[] memory cottonFabricOutset1152PinkChildVoxelTypes = new bytes32[](1);
    cottonFabricOutset1152PinkChildVoxelTypes[0] = CottonFabricOutset1152PinkVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricOutset1152PinkVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Outset1152 Pink",
      CottonFabricOutset1152PinkVoxelID,
      baseVoxelTypeId,
      cottonFabricOutset1152PinkChildVoxelTypes,
      cottonFabricOutset1152PinkChildVoxelTypes,
      CottonFabricOutset1152PinkVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D1152E7_enterWorld.selector,
        IWorld(world).pretty_C38D1152E7_exitWorld.selector,
        IWorld(world).pretty_C38D1152E7_variantSelector.selector,
        IWorld(world).pretty_C38D1152E7_activate.selector,
        IWorld(world).pretty_C38D1152E7_eventHandler.selector,
        IWorld(world).pretty_C38D1152E7_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricOutset1152PinkVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricOutset1152PinkVoxelVariantID;
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
