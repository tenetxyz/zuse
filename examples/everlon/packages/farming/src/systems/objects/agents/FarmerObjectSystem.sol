// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-farming/src/codegen/world/IWorld.sol";
import { AgentType } from "@tenet-base-world/src/prototypes/AgentType.sol";
import { registerObjectType } from "@tenet-registry/src/Utils.sol";

import { Position } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { Farmer, FarmerData } from "@tenet-farming/src/codegen/tables/Farmer.sol";

import { VoxelCoord, ObjectProperties, Action } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS, FarmerObjectID } from "@tenet-farming/src/Constants.sol";
import { tryStoppingAction } from "@tenet-world/src/Utils.sol";
import { getObjectProperties } from "@tenet-base-world/src/CallUtils.sol";
import { positionDataToVoxelCoord, getEntityIdFromObjectEntityId, getVoxelCoord } from "@tenet-base-world/src/Utils.sol";

contract FarmerObjectSystem is AgentType {
  function registerObject() public {
    address world = _world();
    registerObjectType(
      REGISTRY_ADDRESS,
      FarmerObjectID,
      world,
      IWorld(world).farming_FarmerObjectSyst_enterWorld.selector,
      IWorld(world).farming_FarmerObjectSyst_exitWorld.selector,
      IWorld(world).farming_FarmerObjectSyst_eventHandler.selector,
      IWorld(world).farming_FarmerObjectSyst_neighbourEventHandler.selector,
      "Farmer",
      ""
    );
  }

  function enterWorld(
    bytes32 objectEntityId,
    VoxelCoord memory coord
  ) public override returns (ObjectProperties memory) {
    address worldAddress = _msgSender();
    ObjectProperties memory objectProperties;
    objectProperties.mass = 10;
    Farmer.set(worldAddress, objectEntityId, FarmerData({ isHungry: false, hasValue: true }));
    return objectProperties;
  }

  function exitWorld(bytes32 objectEntityId, VoxelCoord memory coord) public override {
    address worldAddress = _msgSender();
    Farmer.deleteRecord(worldAddress, objectEntityId);
  }

  function eventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public override returns (Action[] memory) {
    return super.eventHandler(centerObjectEntityId, neighbourObjectEntityIds);
  }

  function stoppingActions(address worldAddress, bytes32 centerObjectEntityId) internal returns (Action[] memory) {
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

  function defaultEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public override returns (Action[] memory) {
    address worldAddress = _msgSender();
    if (Farmer.getIsHungry(worldAddress, centerObjectEntityId)) {
      Farmer.setIsHungry(worldAddress, centerObjectEntityId, false);
    }
    return stoppingActions(worldAddress, centerObjectEntityId);
  }

  function eatEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = super.getCallerAddress();
    Farmer.setIsHungry(worldAddress, centerObjectEntityId, true);
    return stoppingActions(worldAddress, centerObjectEntityId);
  }

  function neighbourEventHandler(
    bytes32 neighbourObjectEntityId,
    bytes32 centerObjectEntityId
  ) public override returns (bool, Action[] memory) {
    return (false, new Action[](0));
  }
}
