// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { ObjectType } from "@tenet-base-world/src/prototypes/ObjectType.sol";
import { registerObjectType } from "@tenet-registry/src/Utils.sol";
import { VoxelCoord, ObjectProperties, Action } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS, FaucetObjectID } from "@tenet-world/src/Constants.sol";

uint256 constant NUM_AGENTS_PER_FAUCET = 100;
uint256 constant STARTING_STAMINA_FROM_FAUCET = 30000;
uint256 constant STARTING_HEALTH_FROM_FAUCET = 100;

contract FaucetObjectSystem is ObjectType {
  function registerBody() public {
    address world = _world();
    registerObjectType(
      REGISTRY_ADDRESS,
      FaucetObjectID,
      world,
      IWorld(world).world_FaucetObjectSyste_enterWorld.selector,
      IWorld(world).world_FaucetObjectSyste_exitWorld.selector,
      IWorld(world).world_FaucetObjectSyste_eventHandler.selector,
      IWorld(world).world_FaucetObjectSyste_neighbourEventHandler.selector,
      "Faucet",
      ""
    );
  }

  function enterWorld(bytes32 entityId, VoxelCoord memory coord) public override returns (ObjectProperties memory) {
    ObjectProperties memory objectProperties;
    objectProperties.mass = 1000000000; // Make faucet really high mass so its hard to mine
    objectProperties.energy = 1000000000;
    objectProperties.stamina = STARTING_STAMINA_FROM_FAUCET * NUM_AGENTS_PER_FAUCET;
    objectProperties.health = STARTING_HEALTH_FROM_FAUCET * NUM_AGENTS_PER_FAUCET;
    return objectProperties;
  }

  function exitWorld(bytes32 entityId, VoxelCoord memory coord) public override {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds
  ) public override returns (Action[] memory) {
    return new Action[](0);
  }

  function neighbourEventHandler(
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public override returns (bool, Action[] memory) {
    return (false, new Action[](0));
  }
}
