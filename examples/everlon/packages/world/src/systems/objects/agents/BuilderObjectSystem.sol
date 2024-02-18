// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IObjectRegistrySystem } from "@tenet-registry/src/codegen/world/IObjectRegistrySystem.sol";
import { AgentType } from "@tenet-base-world/src/prototypes/AgentType.sol";

import { Position } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { AgentAction, AgentActionData } from "@tenet-world/src/codegen/tables/AgentAction.sol";

import { VoxelCoord, ObjectProperties, Action, ActionType, SimTable } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS, BuilderObjectID, PLAYER_MASS } from "@tenet-world/src/Constants.sol";
import { tryStoppingAction } from "@tenet-world/src/Utils.sol";
import { getObjectProperties } from "@tenet-base-world/src/CallUtils.sol";
import { positionDataToVoxelCoord, getEntityIdFromObjectEntityId, getVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { uint256ToInt256 } from "@tenet-utils/src/TypeUtils.sol";

contract BuilderObjectSystem is AgentType {
  function registerObject() public {
    address world = _world();
    IObjectRegistrySystem(REGISTRY_ADDRESS).registerObjectType(
      BuilderObjectID,
      world,
      IWorld(world).world_BuilderObjectSys_enterWorld.selector,
      IWorld(world).world_BuilderObjectSys_exitWorld.selector,
      IWorld(world).world_BuilderObjectSys_eventHandler.selector,
      IWorld(world).world_BuilderObjectSys_neighbourEventHandler.selector,
      1,
      "Builder",
      ""
    );
  }

  function enterWorld(
    bytes32 objectEntityId,
    VoxelCoord memory coord
  ) public override returns (ObjectProperties memory) {
    ObjectProperties memory objectProperties;
    objectProperties.mass = PLAYER_MASS;
    return objectProperties;
  }

  function exitWorld(bytes32 objectEntityId, VoxelCoord memory coord) public override {
    AgentActionData memory agentAction = AgentAction.get(objectEntityId);
    if (agentAction.isHit) {
      AgentAction.deleteRecord(objectEntityId);
    }
  }

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
    AgentActionData memory agentAction = AgentAction.get(centerObjectEntityId);
    if (agentAction.isHit) {
      return hitActionEventHandler(centerObjectEntityId, neighbourObjectEntityIds);
    }

    return new Action[](0);
  }

  function hitActionEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    // ObjectProperties memory entityProperties = getObjectProperties(worldAddress, centerObjectEntityId);
    // VoxelCoord memory coord = getVoxelCoord(IStore(worldAddress), centerObjectEntityId);

    AgentActionData memory agentAction = AgentAction.get(centerObjectEntityId);

    bytes32 targetObjectEntityId = agentAction.targetObjectEntityId;
    VoxelCoord memory targetCoord = getVoxelCoord(IStore(worldAddress), targetObjectEntityId);

    int256 damage = -1 * uint256ToInt256(uint256(agentAction.damage));

    uint256 transferStamina = 0; // TODO: calculate and don't send event if we dont have enough stamina
    Action memory hitAction = Action({
      actionType: ActionType.Transfer,
      senderTable: SimTable.Stamina,
      senderValue: abi.encode(uint256ToInt256(transferStamina)),
      targetObjectEntityId: targetObjectEntityId,
      targetCoord: targetCoord,
      targetTable: SimTable.Health,
      targetValue: abi.encode(damage)
    });
    Action[] memory actions = new Action[](1);
    actions[0] = hitAction;

    // We only want to hit once, so delete the action record
    AgentAction.deleteRecord(centerObjectEntityId);

    return actions;
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
    bytes32 neighbourObjectEntityId,
    bytes32 centerObjectEntityId
  ) public override returns (bool, Action[] memory) {
    return (false, new Action[](0));
  }
}
