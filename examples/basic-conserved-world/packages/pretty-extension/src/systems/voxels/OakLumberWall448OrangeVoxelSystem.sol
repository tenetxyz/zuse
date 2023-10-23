// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberWall448OrangeVoxelID = bytes32(keccak256("oak_lumber_wall_448_orange"));
bytes32 constant OakLumberWall448OrangeVoxelVariantID = bytes32(keccak256("oak_lumber_wall_448_orange"));

contract OakLumberWall448OrangeVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberWall448OrangeVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberWall448OrangeVoxelVariantID, oakLumberWall448OrangeVariant);

    bytes32[] memory oakLumberWall448OrangeChildVoxelTypes = new bytes32[](1);
    oakLumberWall448OrangeChildVoxelTypes[0] = OakLumberWall448OrangeVoxelID;
    bytes32 baseVoxelTypeId = OakLumberWall448OrangeVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Wall448 Orange",
      OakLumberWall448OrangeVoxelID,
      baseVoxelTypeId,
      oakLumberWall448OrangeChildVoxelTypes,
      oakLumberWall448OrangeChildVoxelTypes,
      OakLumberWall448OrangeVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D448E4_enterWorld.selector,
        IWorld(world).pretty_C31D448E4_exitWorld.selector,
        IWorld(world).pretty_C31D448E4_variantSelector.selector,
        IWorld(world).pretty_C31D448E4_activate.selector,
        IWorld(world).pretty_C31D448E4_eventHandler.selector,
        IWorld(world).pretty_C31D448E4_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberWall448OrangeVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberWall448OrangeVoxelVariantID;
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
