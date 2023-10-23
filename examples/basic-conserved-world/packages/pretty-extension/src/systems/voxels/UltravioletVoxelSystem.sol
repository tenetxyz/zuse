// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant UltravioletVoxelID = bytes32(keccak256("ultraviolet"));
bytes32 constant UltravioletVoxelVariantID = bytes32(keccak256("ultraviolet"));

contract UltravioletVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory ultravioletVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, UltravioletVoxelVariantID, ultravioletVariant);

    bytes32[] memory ultravioletChildVoxelTypes = new bytes32[](1);
    ultravioletChildVoxelTypes[0] = UltravioletVoxelID;
    bytes32 baseVoxelTypeId = UltravioletVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Ultraviolet",
      UltravioletVoxelID,
      baseVoxelTypeId,
      ultravioletChildVoxelTypes,
      ultravioletChildVoxelTypes,
      UltravioletVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C16777261_enterWorld.selector,
        IWorld(world).pretty_C16777261_exitWorld.selector,
        IWorld(world).pretty_C16777261_variantSelector.selector,
        IWorld(world).pretty_C16777261_activate.selector,
        IWorld(world).pretty_C16777261_eventHandler.selector,
        IWorld(world).pretty_C16777261_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, UltravioletVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return UltravioletVoxelVariantID;
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
