// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { AgentType } from "@tenet-base-world/src/prototypes/AgentType.sol";
import { registerObjectType } from "@tenet-registry/src/Utils.sol";
import { VoxelCoord, ObjectProperties, Action, ActionType, SimTable } from "@tenet-utils/src/Types.sol";

import { Position } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";

import { REGISTRY_ADDRESS, FaucetObjectID, AirObjectID, DirtObjectID, GrassObjectID, BedrockObjectID, StoneObjectID } from "@tenet-world/src/Constants.sol";
import { getObjectProperties } from "@tenet-base-world/src/CallUtils.sol";
import { uint256ToNegativeInt256, uint256ToInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { positionDataToVoxelCoord, getMooreNeighbourEntities, getEntityIdFromObjectEntityId } from "@tenet-base-world/src/Utils.sol";

uint256 constant NUM_AGENTS_PER_FAUCET = 100;
uint256 constant STARTING_STAMINA_FROM_FAUCET = 30000;
uint256 constant STARTING_HEALTH_FROM_FAUCET = 100;

contract FaucetObjectSystem is AgentType {
  function registerObject() public {
    address world = _world();
    registerObjectType(
      REGISTRY_ADDRESS,
      FaucetObjectID,
      world,
      IWorld(world).world_FaucetObjectSyst_enterWorld.selector,
      IWorld(world).world_FaucetObjectSyst_exitWorld.selector,
      IWorld(world).world_FaucetObjectSyst_eventHandler.selector,
      IWorld(world).world_FaucetObjectSyst_neighbourEventHandler.selector,
      "Faucet",
      ""
    );
  }

  function enterWorld(
    bytes32 objectEntityId,
    VoxelCoord memory coord
  ) public override returns (ObjectProperties memory) {
    ObjectProperties memory objectProperties;
    objectProperties.mass = 1000000000; // Make faucet really high mass so its hard to mine
    objectProperties.energy = 1000000000;
    objectProperties.stamina = STARTING_STAMINA_FROM_FAUCET * NUM_AGENTS_PER_FAUCET;
    objectProperties.health = STARTING_HEALTH_FROM_FAUCET * NUM_AGENTS_PER_FAUCET;
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
    return giveStaminaAndHealthEventHandler(centerObjectEntityId, neighbourObjectEntityIds);
  }

  function giveStaminaAndHealthEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    ObjectProperties memory entityProperties = getObjectProperties(worldAddress, centerObjectEntityId);

    uint256 currentStamina = entityProperties.stamina;
    uint256 currentHealth = entityProperties.health;
    if (currentStamina == 0 || currentHealth == 0) {
      return new Action[](0);
    }

    (bytes32[] memory neighbourEntities, VoxelCoord[] memory neighbourCoords) = getMooreNeighbourEntities(
      IStore(worldAddress),
      getEntityIdFromObjectEntityId(IStore(worldAddress), centerObjectEntityId),
      1
    );
    Action[] memory actions = new Action[](neighbourEntities.length * 2); // one action for stamina, one for health
    for (uint256 i = 0; i < neighbourEntities.length; i++) {
      if (uint256(neighbourEntities[i]) == 0) {
        continue;
      }
      bytes32 neighbourObjectTypeId = ObjectType.get(IStore(worldAddress), neighbourEntities[i]);
      // TODO: Find a better way to check if the object is an agent
      if (
        neighbourObjectTypeId == AirObjectID ||
        neighbourObjectTypeId == GrassObjectID ||
        neighbourObjectTypeId == DirtObjectID ||
        neighbourObjectTypeId == StoneObjectID ||
        neighbourObjectTypeId == BedrockObjectID
      ) {
        continue;
      }
      bytes32 neighbourObjectEntityId = ObjectEntity.get(IStore(worldAddress), neighbourEntities[i]);
      ObjectProperties memory neighbourEntityProperties = getObjectProperties(worldAddress, neighbourObjectEntityId);
      if (neighbourEntityProperties.stamina == 0 && neighbourEntityProperties.health == 0) {
        uint256 transferStamina = STARTING_STAMINA_FROM_FAUCET;
        uint256 transferHealth = STARTING_HEALTH_FROM_FAUCET;
        if (currentStamina < transferStamina || currentHealth < transferHealth) {
          break;
        }
        currentStamina -= transferStamina;
        currentHealth -= transferHealth;

        actions[i * 2] = Action({
          actionType: ActionType.Transfer,
          senderTable: SimTable.Stamina,
          senderValue: abi.encode(uint256ToNegativeInt256(transferStamina)),
          targetObjectEntityId: neighbourObjectEntityId,
          targetCoord: neighbourCoords[i],
          targetTable: SimTable.Stamina,
          targetValue: abi.encode(uint256ToInt256(transferStamina))
        });
        actions[i * 2 + 1] = Action({
          actionType: ActionType.Transfer,
          senderTable: SimTable.Health,
          senderValue: abi.encode(uint256ToNegativeInt256(transferHealth)),
          targetObjectEntityId: neighbourObjectEntityId,
          targetCoord: neighbourCoords[i],
          targetTable: SimTable.Health,
          targetValue: abi.encode(uint256ToInt256(transferHealth))
        });
      }
    }

    return actions;
  }

  function neighbourEventHandler(
    bytes32 neighbourEntityId,
    bytes32 centerObjectEntityId
  ) public override returns (bool, Action[] memory) {
    return (false, new Action[](0));
  }
}
