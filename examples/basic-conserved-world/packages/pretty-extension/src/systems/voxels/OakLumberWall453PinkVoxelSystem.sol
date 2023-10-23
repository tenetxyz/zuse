// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberWall453PinkVoxelID = bytes32(keccak256("oak_lumber_wall_453_pink"));
bytes32 constant OakLumberWall453PinkVoxelVariantID = bytes32(keccak256("oak_lumber_wall_453_pink"));

contract OakLumberWall453PinkVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberWall453PinkVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberWall453PinkVoxelVariantID, oakLumberWall453PinkVariant);

    bytes32[] memory oakLumberWall453PinkChildVoxelTypes = new bytes32[](1);
    oakLumberWall453PinkChildVoxelTypes[0] = OakLumberWall453PinkVoxelID;
    bytes32 baseVoxelTypeId = OakLumberWall453PinkVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Wall453 Pink",
      OakLumberWall453PinkVoxelID,
      baseVoxelTypeId,
      oakLumberWall453PinkChildVoxelTypes,
      oakLumberWall453PinkChildVoxelTypes,
      OakLumberWall453PinkVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D453E7_enterWorld.selector,
        IWorld(world).pretty_C31D453E7_exitWorld.selector,
        IWorld(world).pretty_C31D453E7_variantSelector.selector,
        IWorld(world).pretty_C31D453E7_activate.selector,
        IWorld(world).pretty_C31D453E7_eventHandler.selector,
        IWorld(world).pretty_C31D453E7_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberWall453PinkVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberWall453PinkVoxelVariantID;
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
