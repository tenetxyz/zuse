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
import { positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";

contract BuilderObjectSystem is AgentType {
  function registerBody() public {
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

  function enterWorld(bytes32 entityId, VoxelCoord memory coord) public override returns (ObjectProperties memory) {
    ObjectProperties memory objectProperties;
    objectProperties.mass = 10;
    return objectProperties;
  }

  function exitWorld(bytes32 entityId, VoxelCoord memory coord) public override {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds
  ) public override returns (Action[] memory) {
    return super.eventHandler(centerEntityId, neighbourEntityIds);
  }

  function stopActionEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = super.getCallerAddress();
    ObjectProperties memory entityProperties = getObjectProperties(worldAddress, centerEntityId);
    VoxelCoord memory coord = positionDataToVoxelCoord(Position.get(IStore(worldAddress), centerEntityId));
    (bool hasStopAction, Action memory stopAction) = tryStoppingAction(centerEntityId, coord, entityProperties);
    if (!hasStopAction) {
      return new Action[](0);
    }
    Action[] memory actions = new Action[](1);
    actions[0] = stopAction;
    return actions;
  }

  function neighbourEventHandler(
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public override returns (bool, Action[] memory) {
    return (false, new Action[](0));
  }
}
