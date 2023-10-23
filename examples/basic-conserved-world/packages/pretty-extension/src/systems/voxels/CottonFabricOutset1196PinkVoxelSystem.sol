// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricOutset1196PinkVoxelID = bytes32(keccak256("cotton_fabric_outset_1196_pink"));
bytes32 constant CottonFabricOutset1196PinkVoxelVariantID = bytes32(keccak256("cotton_fabric_outset_1196_pink"));

contract CottonFabricOutset1196PinkVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricOutset1196PinkVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricOutset1196PinkVoxelVariantID, cottonFabricOutset1196PinkVariant);

    bytes32[] memory cottonFabricOutset1196PinkChildVoxelTypes = new bytes32[](1);
    cottonFabricOutset1196PinkChildVoxelTypes[0] = CottonFabricOutset1196PinkVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricOutset1196PinkVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Outset1196 Pink",
      CottonFabricOutset1196PinkVoxelID,
      baseVoxelTypeId,
      cottonFabricOutset1196PinkChildVoxelTypes,
      cottonFabricOutset1196PinkChildVoxelTypes,
      CottonFabricOutset1196PinkVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D1196E7_enterWorld.selector,
        IWorld(world).pretty_C38D1196E7_exitWorld.selector,
        IWorld(world).pretty_C38D1196E7_variantSelector.selector,
        IWorld(world).pretty_C38D1196E7_activate.selector,
        IWorld(world).pretty_C38D1196E7_eventHandler.selector,
        IWorld(world).pretty_C38D1196E7_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricOutset1196PinkVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricOutset1196PinkVoxelVariantID;
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
