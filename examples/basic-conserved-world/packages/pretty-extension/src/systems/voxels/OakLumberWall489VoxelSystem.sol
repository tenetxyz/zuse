// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberWall489VoxelID = bytes32(keccak256("oak_lumber_wall_489"));
bytes32 constant OakLumberWall489VoxelVariantID = bytes32(keccak256("oak_lumber_wall_489"));

contract OakLumberWall489VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberWall489Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberWall489VoxelVariantID, oakLumberWall489Variant);

    bytes32[] memory oakLumberWall489ChildVoxelTypes = new bytes32[](1);
    oakLumberWall489ChildVoxelTypes[0] = OakLumberWall489VoxelID;
    bytes32 baseVoxelTypeId = OakLumberWall489VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Wall489",
      OakLumberWall489VoxelID,
      baseVoxelTypeId,
      oakLumberWall489ChildVoxelTypes,
      oakLumberWall489ChildVoxelTypes,
      OakLumberWall489VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D489_enterWorld.selector,
        IWorld(world).pretty_C31D489_exitWorld.selector,
        IWorld(world).pretty_C31D489_variantSelector.selector,
        IWorld(world).pretty_C31D489_activate.selector,
        IWorld(world).pretty_C31D489_eventHandler.selector,
        IWorld(world).pretty_C31D489_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberWall489VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberWall489VoxelVariantID;
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
