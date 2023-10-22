// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLogWall448VoxelID = bytes32(keccak256("oak_log_wall_448"));
bytes32 constant OakLogWall448VoxelVariantID = bytes32(keccak256("oak_log_wall_448"));

contract OakLogWall448VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLogWall448Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLogWall448VoxelVariantID, oakLogWall448Variant);

    bytes32[] memory oakLogWall448ChildVoxelTypes = new bytes32[](1);
    oakLogWall448ChildVoxelTypes[0] = OakLogWall448VoxelID;
    bytes32 baseVoxelTypeId = OakLogWall448VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Log Wall448",
      OakLogWall448VoxelID,
      baseVoxelTypeId,
      oakLogWall448ChildVoxelTypes,
      oakLogWall448ChildVoxelTypes,
      OakLogWall448VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C3448_enterWorld.selector,
        IWorld(world).pretty_C3448_exitWorld.selector,
        IWorld(world).pretty_C3448_variantSelector.selector,
        IWorld(world).pretty_C3448_activate.selector,
        IWorld(world).pretty_C3448_eventHandler.selector,
        IWorld(world).pretty_C3448_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLogWall448VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLogWall448VoxelVariantID;
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
