// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { AgentType } from "@tenet-base-world/src/prototypes/AgentType.sol";
import { registerObjectType } from "@tenet-registry/src/Utils.sol";

import { Position } from "@tenet-base-world/src/codegen/tables/Position.sol";

import { VoxelCoord, ObjectProperties, Action } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS, BuilderObjectID } from "@tenet-world/src/Constants.sol";
import { tryStoppingAction } from "@tenet-world/src/Utils.sol";
import { getObjectProperties } from "@tenet-base-world/src/CallUtils.sol";
import { positionDataToVoxelCoord, getEntityIdFromObjectEntityId, getVoxelCoord } from "@tenet-base-world/src/Utils.sol";

contract BuilderObjectSystem is AgentType {
  function registerObject() public {
    address world = _world();
    registerObjectType(
      REGISTRY_ADDRESS,
      BuilderObjectID,
      world,
      IWorld(world).world_BuilderObjectSys_enterWorld.selector,
      IWorld(world).world_BuilderObjectSys_exitWorld.selector,
      IWorld(world).world_BuilderObjectSys_eventHandler.selector,
      IWorld(world).world_BuilderObjectSys_neighbourEventHandler.selector,
      "Builder",
      ""
    );
  }

  function enterWorld(
    bytes32 objectEntityId,
    VoxelCoord memory coord
  ) public override returns (ObjectProperties memory) {
    ObjectProperties memory objectProperties;
    objectProperties.mass = 10;
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
    return stopActionEventHandler(centerObjectEntityId, neighbourObjectEntityIds);
  }

  function stopActionEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    ObjectProperties memory entityProperties = getObjectProperties(worldAddress, centerObjectEntityId);
    VoxelCoord memory coord = getVoxelCoord(IStore(worldAddress), centerObjectEntityId);
    (bool hasStopAction, Action memory stopAction) = tryStoppingAction(centerObjectEntityId, coord, entityProperties);
    if (!hasStopAction) {
      return new Action[](0);
    }
    Action[] memory actions = new Action[](1);
    actions[0] = stopAction;
    return actions;
  }

  function neighbourEventHandler(
    bytes32 neighbourEntityId,
    bytes32 centerObjectEntityId
  ) public override returns (bool, Action[] memory) {
    return (false, new Action[](0));
  }
}
