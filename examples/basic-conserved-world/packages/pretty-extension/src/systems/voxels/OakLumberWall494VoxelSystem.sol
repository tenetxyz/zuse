// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberWall494VoxelID = bytes32(keccak256("oak_lumber_wall_494"));
bytes32 constant OakLumberWall494VoxelVariantID = bytes32(keccak256("oak_lumber_wall_494"));

contract OakLumberWall494VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberWall494Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberWall494VoxelVariantID, oakLumberWall494Variant);

    bytes32[] memory oakLumberWall494ChildVoxelTypes = new bytes32[](1);
    oakLumberWall494ChildVoxelTypes[0] = OakLumberWall494VoxelID;
    bytes32 baseVoxelTypeId = OakLumberWall494VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Wall494",
      OakLumberWall494VoxelID,
      baseVoxelTypeId,
      oakLumberWall494ChildVoxelTypes,
      oakLumberWall494ChildVoxelTypes,
      OakLumberWall494VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D494_enterWorld.selector,
        IWorld(world).pretty_C31D494_exitWorld.selector,
        IWorld(world).pretty_C31D494_variantSelector.selector,
        IWorld(world).pretty_C31D494_activate.selector,
        IWorld(world).pretty_C31D494_eventHandler.selector,
        IWorld(world).pretty_C31D494_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberWall494VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberWall494VoxelVariantID;
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
