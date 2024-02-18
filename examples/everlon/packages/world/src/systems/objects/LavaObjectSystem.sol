// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { ObjectType } from "@tenet-base-world/src/prototypes/ObjectType.sol";
import { IObjectRegistrySystem } from "@tenet-registry/src/codegen/world/IObjectRegistrySystem.sol";
import { VoxelCoord, ObjectProperties, Action } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS, NUM_BLOCK_STACKABLE, LavaObjectID, LAVA_MASS } from "@tenet-world/src/Constants.sol";

contract LavaObjectSystem is ObjectType {
  function registerObject() public {
    address world = _world();
    IObjectRegistrySystem(REGISTRY_ADDRESS).registerObjectType(
      LavaObjectID,
      world,
      IWorld(world).world_LavaObjectSystem_enterWorld.selector,
      IWorld(world).world_LavaObjectSystem_exitWorld.selector,
      IWorld(world).world_LavaObjectSystem_eventHandler.selector,
      IWorld(world).world_LavaObjectSystem_neighbourEventHandler.selector,
      NUM_BLOCK_STACKABLE,
      0,
      "Lava"
    );
  }

  function enterWorld(
    bytes32 objectEntityId,
    VoxelCoord memory coord
  ) public override returns (ObjectProperties memory) {
    ObjectProperties memory objectProperties;
    objectProperties.mass = LAVA_MASS;
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
