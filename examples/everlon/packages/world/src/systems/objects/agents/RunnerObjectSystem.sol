// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { AgentType } from "@tenet-base-world/src/prototypes/AgentType.sol";
import { registerObjectType } from "@tenet-registry/src/Utils.sol";

import { Position } from "@tenet-base-world/src/codegen/tables/Position.sol";

import { VoxelCoord, ObjectProperties, Action } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS, RunnerObjectID } from "@tenet-world/src/Constants.sol";
import { getObjectProperties } from "@tenet-base-world/src/CallUtils.sol";

contract RunnerObjectSystem is AgentType {
  function registerBody() public {
    address world = _world();
    registerObjectType(
      REGISTRY_ADDRESS,
      RunnerObjectID,
      world,
      IWorld(world).world_RunnerObjectSyst_enterWorld.selector,
      IWorld(world).world_RunnerObjectSyst_exitWorld.selector,
      IWorld(world).world_RunnerObjectSyst_eventHandler.selector,
      IWorld(world).world_RunnerObjectSyst_neighbourEventHandler.selector,
      "Runner",
      ""
    );
  }

  function enterWorld(bytes32 entityId, VoxelCoord memory coord) public override returns (ObjectProperties memory) {
    ObjectProperties memory objectProperties;
    objectProperties.mass = 50; // high mass so when it collides, it causes objects to move
    return objectProperties;
  }

  function exitWorld(bytes32 entityId, VoxelCoord memory coord) public override {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds
  ) public override returns (Action[] memory) {
    return super.eventHandler(centerEntityId, neighbourEntityIds);
  }

  function neighbourEventHandler(
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public override returns (bool, Action[] memory) {
    return (false, new Action[](0));
  }
}
