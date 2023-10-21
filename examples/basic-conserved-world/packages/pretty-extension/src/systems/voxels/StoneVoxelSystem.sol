// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant StoneVoxelID = bytes32(keccak256("stone"));
bytes32 constant StoneVoxelVariantID = bytes32(keccak256("stone"));

contract StoneVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory stoneVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, StoneVoxelVariantID, stoneVariant);

    bytes32[] memory stoneChildVoxelTypes = new bytes32[](1);
    stoneChildVoxelTypes[0] = StoneVoxelID;
    bytes32 baseVoxelTypeId = StoneVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Stone",
      StoneVoxelID,
      baseVoxelTypeId,
      stoneChildVoxelTypes,
      stoneChildVoxelTypes,
      StoneVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C4_enterWorld.selector,
        IWorld(world).pretty_C4_exitWorld.selector,
        IWorld(world).pretty_C4_variantSelector.selector,
        IWorld(world).pretty_C4_activate.selector,
        IWorld(world).pretty_C4_eventHandler.selector,
        IWorld(world).pretty_C4_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, StoneVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return StoneVoxelVariantID;
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
