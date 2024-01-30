// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { ObjectType } from "@tenet-base-world/src/prototypes/ObjectType.sol";
import { IObjectRegistrySystem } from "@tenet-registry/src/codegen/world/IObjectRegistrySystem.sol";
import { VoxelCoord, ObjectProperties, Action } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS, QuartziteObjectID, SIMPLE_BLOCK_MASS } from "@tenet-world/src/Constants.sol";

contract QuartziteObjectSystem is ObjectType {
  function registerObject() public {
    address world = _world();
    IObjectRegistrySystem(REGISTRY_ADDRESS).registerObjectType(
      QuartziteObjectID,
      world,
      IWorld(world).world_QuartziteObjectS_enterWorld.selector,
      IWorld(world).world_QuartziteObjectS_exitWorld.selector,
      IWorld(world).world_QuartziteObjectS_eventHandler.selector,
      IWorld(world).world_QuartziteObjectS_neighbourEventHandler.selector,
      "Quartzite",
      ""
    );
  }

  function enterWorld(
    bytes32 objectEntityId,
    VoxelCoord memory coord
  ) public override returns (ObjectProperties memory) {
    ObjectProperties memory objectProperties;
    objectProperties.mass = SIMPLE_BLOCK_MASS;
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