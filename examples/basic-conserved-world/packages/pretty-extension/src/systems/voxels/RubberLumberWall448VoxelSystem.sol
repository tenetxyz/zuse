// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberLumberWall448VoxelID = bytes32(keccak256("rubber_lumber_wall_448"));
bytes32 constant RubberLumberWall448VoxelVariantID = bytes32(keccak256("rubber_lumber_wall_448"));

contract RubberLumberWall448VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberLumberWall448Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberLumberWall448VoxelVariantID, rubberLumberWall448Variant);

    bytes32[] memory rubberLumberWall448ChildVoxelTypes = new bytes32[](1);
    rubberLumberWall448ChildVoxelTypes[0] = RubberLumberWall448VoxelID;
    bytes32 baseVoxelTypeId = RubberLumberWall448VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Lumber Wall448",
      RubberLumberWall448VoxelID,
      baseVoxelTypeId,
      rubberLumberWall448ChildVoxelTypes,
      rubberLumberWall448ChildVoxelTypes,
      RubberLumberWall448VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C34D448_enterWorld.selector,
        IWorld(world).pretty_C34D448_exitWorld.selector,
        IWorld(world).pretty_C34D448_variantSelector.selector,
        IWorld(world).pretty_C34D448_activate.selector,
        IWorld(world).pretty_C34D448_eventHandler.selector,
        IWorld(world).pretty_C34D448_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberLumberWall448VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberLumberWall448VoxelVariantID;
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
