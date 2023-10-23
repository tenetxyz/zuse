// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricOutset1152YellowVoxelID = bytes32(keccak256("cotton_fabric_outset_1152_yellow"));
bytes32 constant CottonFabricOutset1152YellowVoxelVariantID = bytes32(keccak256("cotton_fabric_outset_1152_yellow"));

contract CottonFabricOutset1152YellowVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricOutset1152YellowVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricOutset1152YellowVoxelVariantID, cottonFabricOutset1152YellowVariant);

    bytes32[] memory cottonFabricOutset1152YellowChildVoxelTypes = new bytes32[](1);
    cottonFabricOutset1152YellowChildVoxelTypes[0] = CottonFabricOutset1152YellowVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricOutset1152YellowVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Outset1152 Yellow",
      CottonFabricOutset1152YellowVoxelID,
      baseVoxelTypeId,
      cottonFabricOutset1152YellowChildVoxelTypes,
      cottonFabricOutset1152YellowChildVoxelTypes,
      CottonFabricOutset1152YellowVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D1152E8_enterWorld.selector,
        IWorld(world).pretty_C38D1152E8_exitWorld.selector,
        IWorld(world).pretty_C38D1152E8_variantSelector.selector,
        IWorld(world).pretty_C38D1152E8_activate.selector,
        IWorld(world).pretty_C38D1152E8_eventHandler.selector,
        IWorld(world).pretty_C38D1152E8_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricOutset1152YellowVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricOutset1152YellowVoxelVariantID;
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
