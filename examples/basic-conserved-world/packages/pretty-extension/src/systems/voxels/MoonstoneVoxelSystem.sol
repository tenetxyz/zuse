// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant MoonstoneVoxelID = bytes32(keccak256("moonstone"));
bytes32 constant MoonstoneVoxelVariantID = bytes32(keccak256("moonstone"));

contract MoonstoneVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory moonstoneVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, MoonstoneVoxelVariantID, moonstoneVariant);

    bytes32[] memory moonstoneChildVoxelTypes = new bytes32[](1);
    moonstoneChildVoxelTypes[0] = MoonstoneVoxelID;
    bytes32 baseVoxelTypeId = MoonstoneVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Moonstone",
      MoonstoneVoxelID,
      baseVoxelTypeId,
      moonstoneChildVoxelTypes,
      moonstoneChildVoxelTypes,
      MoonstoneVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C67_enterWorld.selector,
        IWorld(world).pretty_C67_exitWorld.selector,
        IWorld(world).pretty_C67_variantSelector.selector,
        IWorld(world).pretty_C67_activate.selector,
        IWorld(world).pretty_C67_eventHandler.selector,
        IWorld(world).pretty_C67_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, MoonstoneVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return MoonstoneVoxelVariantID;
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
