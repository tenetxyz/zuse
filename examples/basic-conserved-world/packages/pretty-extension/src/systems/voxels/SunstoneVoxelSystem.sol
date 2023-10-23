// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant SunstoneVoxelID = bytes32(keccak256("sunstone"));
bytes32 constant SunstoneVoxelVariantID = bytes32(keccak256("sunstone"));

contract SunstoneVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory sunstoneVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, SunstoneVoxelVariantID, sunstoneVariant);

    bytes32[] memory sunstoneChildVoxelTypes = new bytes32[](1);
    sunstoneChildVoxelTypes[0] = SunstoneVoxelID;
    bytes32 baseVoxelTypeId = SunstoneVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Sunstone",
      SunstoneVoxelID,
      baseVoxelTypeId,
      sunstoneChildVoxelTypes,
      sunstoneChildVoxelTypes,
      SunstoneVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C66_enterWorld.selector,
        IWorld(world).pretty_C66_exitWorld.selector,
        IWorld(world).pretty_C66_variantSelector.selector,
        IWorld(world).pretty_C66_activate.selector,
        IWorld(world).pretty_C66_eventHandler.selector,
        IWorld(world).pretty_C66_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, SunstoneVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return SunstoneVoxelVariantID;
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
