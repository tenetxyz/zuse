// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { ObjectType } from "@tenet-base-world/src/prototypes/ObjectType.sol";
import { IObjectRegistrySystem } from "@tenet-registry/src/codegen/world/IObjectRegistrySystem.sol";
import { VoxelCoord, ObjectProperties, Action } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS, NUM_BLOCK_STACKABLE, OakLeafObjectID, OAK_LEAF_MASS } from "@tenet-world/src/Constants.sol";

contract OakLeafObjectSystem is ObjectType {
  function registerObject() public {
    address world = _world();
    IObjectRegistrySystem(REGISTRY_ADDRESS).registerObjectType(
      OakLeafObjectID,
      world,
      IWorld(world).world_OakLeafObjectSys_enterWorld.selector,
      IWorld(world).world_OakLeafObjectSys_exitWorld.selector,
      IWorld(world).world_OakLeafObjectSys_eventHandler.selector,
      IWorld(world).world_OakLeafObjectSys_neighbourEventHandler.selector,
      NUM_BLOCK_STACKABLE,
      "Oak Leaf",
      ""
    );
  }

  function enterWorld(
    bytes32 objectEntityId,
    VoxelCoord memory coord
  ) public override returns (ObjectProperties memory) {
    ObjectProperties memory objectProperties;
    objectProperties.mass = OAK_LEAF_MASS;
    return objectProperties;
  }

  function exitWorld(bytes32 objectEntityId, VoxelCoord memory coord) public override {}

  function eventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public override returns (Action[] memory) {
    return new Action[](0);
  }

  function neighbourEventHandler(
    bytes32 neighbourObjectEntityId,
    bytes32 centerObjectEntityId
  ) public override returns (bool, Action[] memory) {
    return (false, new Action[](0));
  }
}
