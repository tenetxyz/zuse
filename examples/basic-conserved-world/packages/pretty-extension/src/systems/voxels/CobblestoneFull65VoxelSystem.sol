// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CobblestoneFull65VoxelID = bytes32(keccak256("cobblestone_full_65"));
bytes32 constant CobblestoneFull65VoxelVariantID = bytes32(keccak256("cobblestone_full_65"));

contract CobblestoneFull65VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cobblestoneFull65Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CobblestoneFull65VoxelVariantID, cobblestoneFull65Variant);

    bytes32[] memory cobblestoneFull65ChildVoxelTypes = new bytes32[](1);
    cobblestoneFull65ChildVoxelTypes[0] = CobblestoneFull65VoxelID;
    bytes32 baseVoxelTypeId = CobblestoneFull65VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cobblestone Full65",
      CobblestoneFull65VoxelID,
      baseVoxelTypeId,
      cobblestoneFull65ChildVoxelTypes,
      cobblestoneFull65ChildVoxelTypes,
      CobblestoneFull65VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C5D65_enterWorld.selector,
        IWorld(world).pretty_C5D65_exitWorld.selector,
        IWorld(world).pretty_C5D65_variantSelector.selector,
        IWorld(world).pretty_C5D65_activate.selector,
        IWorld(world).pretty_C5D65_eventHandler.selector,
        IWorld(world).pretty_C5D65_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CobblestoneFull65VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CobblestoneFull65VoxelVariantID;
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
