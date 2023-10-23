// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant HayWall489VoxelID = bytes32(keccak256("hay_wall_489"));
bytes32 constant HayWall489VoxelVariantID = bytes32(keccak256("hay_wall_489"));

contract HayWall489VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory hayWall489Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, HayWall489VoxelVariantID, hayWall489Variant);

    bytes32[] memory hayWall489ChildVoxelTypes = new bytes32[](1);
    hayWall489ChildVoxelTypes[0] = HayWall489VoxelID;
    bytes32 baseVoxelTypeId = HayWall489VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Hay Wall489",
      HayWall489VoxelID,
      baseVoxelTypeId,
      hayWall489ChildVoxelTypes,
      hayWall489ChildVoxelTypes,
      HayWall489VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C35D489_enterWorld.selector,
        IWorld(world).pretty_C35D489_exitWorld.selector,
        IWorld(world).pretty_C35D489_variantSelector.selector,
        IWorld(world).pretty_C35D489_activate.selector,
        IWorld(world).pretty_C35D489_eventHandler.selector,
        IWorld(world).pretty_C35D489_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, HayWall489VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return HayWall489VoxelVariantID;
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
