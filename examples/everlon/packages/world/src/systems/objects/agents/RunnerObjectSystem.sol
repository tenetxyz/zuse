// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IObjectRegistrySystem } from "@tenet-registry/src/codegen/world/IObjectRegistrySystem.sol";
import { AgentType } from "@tenet-base-world/src/prototypes/AgentType.sol";

import { Position } from "@tenet-base-world/src/codegen/tables/Position.sol";

import { VoxelCoord, ObjectProperties, Action } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS, RunnerObjectID } from "@tenet-world/src/Constants.sol";
import { getObjectProperties } from "@tenet-base-world/src/CallUtils.sol";

contract RunnerObjectSystem is AgentType {
  function registerObject() public {
    address world = _world();
    IObjectRegistrySystem(REGISTRY_ADDRESS).registerObjectType(
      RunnerObjectID,
      world,
      IWorld(world).world_RunnerObjectSyst_enterWorld.selector,
      IWorld(world).world_RunnerObjectSyst_exitWorld.selector,
      IWorld(world).world_RunnerObjectSyst_eventHandler.selector,
      IWorld(world).world_RunnerObjectSyst_neighbourEventHandler.selector,
      1,
      "Runner",
      ""
    );
  }

  function enterWorld(
    bytes32 objectEntityId,
    VoxelCoord memory coord
  ) public override returns (ObjectProperties memory) {
    ObjectProperties memory objectProperties;
    objectProperties.mass = 50; // high mass so when it collides, it causes objects to move
    return objectProperties;
  }

  function exitWorld(bytes32 objectEntityId, VoxelCoord memory coord) public override {}

  function eventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public override returns (Action[] memory) {
    return super.eventHandler(centerObjectEntityId, neighbourObjectEntityIds);
  }

  function defaultEventHandler(
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
