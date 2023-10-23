// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricStep236YellowVoxelID = bytes32(keccak256("cotton_fabric_step_236_yellow"));
bytes32 constant CottonFabricStep236YellowVoxelVariantID = bytes32(keccak256("cotton_fabric_step_236_yellow"));

contract CottonFabricStep236YellowVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricStep236YellowVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricStep236YellowVoxelVariantID, cottonFabricStep236YellowVariant);

    bytes32[] memory cottonFabricStep236YellowChildVoxelTypes = new bytes32[](1);
    cottonFabricStep236YellowChildVoxelTypes[0] = CottonFabricStep236YellowVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricStep236YellowVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Step236 Yellow",
      CottonFabricStep236YellowVoxelID,
      baseVoxelTypeId,
      cottonFabricStep236YellowChildVoxelTypes,
      cottonFabricStep236YellowChildVoxelTypes,
      CottonFabricStep236YellowVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D236E8_enterWorld.selector,
        IWorld(world).pretty_C38D236E8_exitWorld.selector,
        IWorld(world).pretty_C38D236E8_variantSelector.selector,
        IWorld(world).pretty_C38D236E8_activate.selector,
        IWorld(world).pretty_C38D236E8_eventHandler.selector,
        IWorld(world).pretty_C38D236E8_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricStep236YellowVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricStep236YellowVoxelVariantID;
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
