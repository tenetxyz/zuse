// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant HayVoxelID = bytes32(keccak256("hay"));
bytes32 constant HayVoxelVariantID = bytes32(keccak256("hay"));

contract HayVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory hayVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, HayVoxelVariantID, hayVariant);

    bytes32[] memory hayChildVoxelTypes = new bytes32[](1);
    hayChildVoxelTypes[0] = HayVoxelID;
    bytes32 baseVoxelTypeId = HayVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Hay",
      HayVoxelID,
      baseVoxelTypeId,
      hayChildVoxelTypes,
      hayChildVoxelTypes,
      HayVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C35_enterWorld.selector,
        IWorld(world).pretty_C35_exitWorld.selector,
        IWorld(world).pretty_C35_variantSelector.selector,
        IWorld(world).pretty_C35_activate.selector,
        IWorld(world).pretty_C35_eventHandler.selector,
        IWorld(world).pretty_C35_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, HayVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return HayVoxelVariantID;
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
