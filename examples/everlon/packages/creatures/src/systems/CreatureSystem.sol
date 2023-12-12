// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-creatures/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { VoxelCoord, ObjectProperties, Action, SimTable, ElementType, ActionType } from "@tenet-utils/src/Types.sol";
import { uint256ToNegativeInt256 } from "@tenet-utils/src/TypeUtils.sol";

import { Creature, CreatureData } from "@tenet-creatures/src/codegen/tables/Creature.sol";

import { getObjectProperties } from "@tenet-base-world/src/CallUtils.sol";
import { positionDataToVoxelCoord, getEntityIdFromObjectEntityId, getVoxelCoord, getObjectType } from "@tenet-base-world/src/Utils.sol";

import { entityIsCreature } from "@tenet-creatures/src/Utils.sol";
import { CreatureMove, CreatureMoveData } from "@tenet-creatures/src/Types.sol";
import { NUM_BLOCKS_FAINTED } from "@tenet-creatures/src/Constants.sol";
import { tryStoppingAction } from "@tenet-world/src/Utils.sol";

contract CreatureSystem is System {
  function getCreatureMovesData() internal pure returns (CreatureMoveData[] memory) {
    CreatureMoveData[] memory movesData = new CreatureMoveData[](19); // the first value is for CreatureMove.None
    movesData[uint(CreatureMove.Ember)] = CreatureMoveData(1000, 6, 0, ElementType.Fire);
    movesData[uint(CreatureMove.FlameBurst)] = CreatureMoveData(5000, 27, 0, ElementType.Fire);
    movesData[uint(CreatureMove.InfernoClash)] = CreatureMoveData(20000, 90, 0, ElementType.Fire);
    movesData[uint(CreatureMove.SmokeScreen)] = CreatureMoveData(3000, 0, 19, ElementType.Fire);
    movesData[uint(CreatureMove.FireShield)] = CreatureMoveData(7000, 0, 38, ElementType.Fire);
    movesData[uint(CreatureMove.PyroBarrier)] = CreatureMoveData(12000, 0, 54, ElementType.Fire);

    movesData[uint(CreatureMove.WaterGun)] = CreatureMoveData(1000, 6, 0, ElementType.Water);
    movesData[uint(CreatureMove.HydroPump)] = CreatureMoveData(5000, 27, 0, ElementType.Water);
    movesData[uint(CreatureMove.TidalCrash)] = CreatureMoveData(20000, 90, 0, ElementType.Water);
    movesData[uint(CreatureMove.Bubble)] = CreatureMoveData(3000, 0, 19, ElementType.Water);
    movesData[uint(CreatureMove.AquaRing)] = CreatureMoveData(7000, 0, 38, ElementType.Water);
    movesData[uint(CreatureMove.MistVeil)] = CreatureMoveData(12000, 0, 54, ElementType.Water);

    movesData[uint(CreatureMove.VineWhip)] = CreatureMoveData(1000, 6, 0, ElementType.Grass);
    movesData[uint(CreatureMove.SolarBeam)] = CreatureMoveData(5000, 27, 0, ElementType.Grass);
    movesData[uint(CreatureMove.ThornBurst)] = CreatureMoveData(20000, 90, 0, ElementType.Grass);
    movesData[uint(CreatureMove.LeechSeed)] = CreatureMoveData(3000, 0, 19, ElementType.Grass);
    movesData[uint(CreatureMove.Synthesis)] = CreatureMoveData(7000, 0, 38, ElementType.Grass);
    movesData[uint(CreatureMove.VerdantGuard)] = CreatureMoveData(20000, 90, 0, ElementType.Grass);
    return movesData;
  }

  function getCreatureMoveData(CreatureMove move) internal pure returns (CreatureMoveData memory) {
    CreatureMoveData[] memory movesData = getCreatureMovesData();
    return movesData[uint(move)];
  }

  function neighbourEventHandler(
    address worldAddress,
    bytes32 neighbourObjectEntityId,
    bytes32 centerObjectEntityId
  ) public returns (bool, Action[] memory) {
    CreatureData memory creatureData = Creature.get(worldAddress, neighbourObjectEntityId);
    if (!entityIsCreature(worldAddress, centerObjectEntityId)) {
      return (false, new Action[](0));
    }
    ObjectProperties memory entityProperties = getObjectProperties(worldAddress, neighbourObjectEntityId);
    ObjectProperties memory centerEntityProperties = getObjectProperties(worldAddress, centerObjectEntityId);
    if (
      entityProperties.combatMoveData.moveType == ElementType.None &&
      centerEntityProperties.combatMoveData.moveType != ElementType.None
    ) {
      // Note: We need to check if fightingObjectEntityId matches if we want multiple creatures to fight at the same time
      return (true, new Action[](0));
    }

    creatureData = endOfFightLogic(worldAddress, creatureData, entityProperties);
    if (creatureData.isFainted && block.number >= creatureData.lastFaintedBlock + NUM_BLOCKS_FAINTED) {
      creatureData.isFainted = false;
    }
    Creature.set(worldAddress, neighbourObjectEntityId, creatureData);

    return (false, new Action[](0));
  }

  function defaultEventHandler(
    address worldAddress,
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    ObjectProperties memory entityProperties = getObjectProperties(worldAddress, centerObjectEntityId);
    VoxelCoord memory coord = getVoxelCoord(IStore(worldAddress), centerObjectEntityId);
    (bool hasStopAction, Action memory stopAction) = tryStoppingAction(centerObjectEntityId, coord, entityProperties);
    if (hasStopAction) {
      Action[] memory actions = new Action[](1);
      actions[0] = stopAction;
      return actions;
    }
    CreatureData memory creatureData = Creature.get(worldAddress, centerObjectEntityId);
    creatureData = resetStaleFightingObjectEntityId(neighbourObjectEntityIds, creatureData);

    creatureData = endOfFightLogic(worldAddress, creatureData, entityProperties);
    if (creatureData.isFainted && block.number >= creatureData.lastFaintedBlock + NUM_BLOCKS_FAINTED) {
      creatureData.isFainted = false;
    }
    Creature.set(worldAddress, centerObjectEntityId, creatureData);

    return new Action[](0);
  }

  function moveEventHandler(
    address worldAddress,
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds,
    CreatureMove creatureMove
  ) public returns (Action[] memory) {
    ObjectProperties memory entityProperties = getObjectProperties(worldAddress, centerObjectEntityId);
    VoxelCoord memory coord = getVoxelCoord(IStore(worldAddress), centerObjectEntityId);
    {
      (bool hasStopAction, Action memory stopAction) = tryStoppingAction(centerObjectEntityId, coord, entityProperties);
      if (hasStopAction) {
        Action[] memory actions = new Action[](1);
        actions[0] = stopAction;
        return actions;
      }
    }
    CreatureData memory creatureData = Creature.get(worldAddress, centerObjectEntityId);
    creatureData = resetStaleFightingObjectEntityId(neighbourObjectEntityIds, creatureData);

    creatureData = endOfFightLogic(worldAddress, creatureData, entityProperties);
    if (creatureData.isFainted && block.number >= creatureData.lastFaintedBlock + NUM_BLOCKS_FAINTED) {
      creatureData.isFainted = false;
    }

    Action[] memory actions = new Action[](neighbourObjectEntityIds.length);
    bool foundCreature = false;
    for (uint256 i = 0; i < neighbourObjectEntityIds.length; i++) {
      if (uint256(neighbourObjectEntityIds[i]) == 0) {
        continue;
      }

      if (!entityIsCreature(worldAddress, neighbourObjectEntityIds[i])) {
        continue;
      }
      if (foundCreature) {
        // TODO: Support multiple creatures fighting at the same time
        revert("Creature can't fight more than one creature at a time");
      }
      foundCreature = true;
      (actions[i], creatureData) = runCreatureMove(
        worldAddress,
        centerObjectEntityId,
        coord,
        neighbourObjectEntityIds[i],
        creatureData,
        entityProperties,
        creatureMove
      );
      Creature.set(worldAddress, centerObjectEntityId, creatureData);
    }

    return actions;
  }

  function resetStaleFightingObjectEntityId(
    bytes32[] memory neighbourObjectEntityIds,
    CreatureData memory creatureData
  ) internal returns (CreatureData memory) {
    if (creatureData.fightingObjectEntityId == bytes32(0)) {
      return creatureData;
    }
    bool foundFightingObjectEntityId = false;
    for (uint256 i = 0; i < neighbourObjectEntityIds.length; i++) {
      if (neighbourObjectEntityIds[i] == creatureData.fightingObjectEntityId) {
        foundFightingObjectEntityId = true;
        break;
      }
    }
    if (!foundFightingObjectEntityId) {
      creatureData.fightingObjectEntityId = bytes32(0);
    }
    return creatureData;
  }

  function endOfFightLogic(
    address worldAddress,
    CreatureData memory creatureData,
    ObjectProperties memory entityProperties
  ) internal returns (CreatureData memory) {
    if (creatureData.fightingObjectEntityId != bytes32(0)) {
      ObjectProperties memory fightingEntityProperties = getObjectProperties(
        worldAddress,
        creatureData.fightingObjectEntityId
      );
      if (
        (entityProperties.health == 0 || entityProperties.stamina == 0) ||
        (fightingEntityProperties.health == 0 || fightingEntityProperties.stamina == 0)
      ) {
        if (
          (entityProperties.health == 0 || entityProperties.stamina == 0) &&
          (fightingEntityProperties.health == 0 || fightingEntityProperties.stamina == 0)
        ) {
          // both died, no winner
          creatureData.isFainted = true;
          creatureData.lastFaintedBlock = block.number;
        } else if (entityProperties.health == 0 || entityProperties.stamina == 0) {
          // entity died
          creatureData.isFainted = true;
          creatureData.lastFaintedBlock = block.number;
          creatureData.numLosses += 1;
        } else {
          // fighting entity died
          creatureData.numWins += 1;
        }
        creatureData.fightingObjectEntityId = bytes32(0);
      }
    }
    return creatureData;
  }

  function runCreatureMove(
    address worldAddress,
    bytes32 centerObjectEntityId,
    VoxelCoord memory coord,
    bytes32 neighbourObjectEntityId,
    CreatureData memory creatureData,
    ObjectProperties memory entityProperties,
    CreatureMove creatureMove
  ) internal returns (Action memory action, CreatureData memory) {
    if (creatureData.isFainted || block.number < creatureData.lastFaintedBlock + NUM_BLOCKS_FAINTED) {
      return (action, creatureData);
    }

    ObjectProperties memory neighbourEntityProperties = getObjectProperties(worldAddress, neighbourObjectEntityId);
    if (
      entityProperties.health == 0 ||
      entityProperties.stamina == 0 ||
      neighbourEntityProperties.health == 0 ||
      neighbourEntityProperties.stamina == 0
    ) {
      return (action, creatureData);
    }

    if (entityProperties.combatMoveData.moveType != ElementType.None) {
      return (action, creatureData);
    }

    CreatureMoveData memory creatureMoveData = getCreatureMoveData(creatureMove);
    uint staminaAmount = uint(creatureMoveData.stamina);
    bool isAttack = creatureMoveData.damage > 0;

    if (entityProperties.stamina < staminaAmount) {
      return (action, creatureData);
    }

    if (isAttack) {
      action = Action({
        actionType: ActionType.Transfer,
        senderTable: SimTable.Stamina,
        senderValue: abi.encode(uint256ToNegativeInt256(staminaAmount)),
        targetObjectEntityId: neighbourObjectEntityId,
        targetCoord: getVoxelCoord(IStore(worldAddress), neighbourObjectEntityId),
        targetTable: SimTable.CombatMove,
        targetValue: abi.encode(creatureMoveData.moveType)
      });
    } else {
      action = Action({
        actionType: ActionType.Transformation,
        senderTable: SimTable.Stamina,
        senderValue: abi.encode(uint256ToNegativeInt256(staminaAmount)),
        targetObjectEntityId: centerObjectEntityId,
        targetCoord: coord,
        targetTable: SimTable.CombatMove,
        targetValue: abi.encode(creatureMoveData.moveType)
      });
    }

    require(
      creatureData.fightingObjectEntityId == bytes32(0) ||
        creatureData.fightingObjectEntityId == neighbourObjectEntityId,
      "CreatureSystem: Creature is already fighting"
    );
    creatureData.fightingObjectEntityId = neighbourObjectEntityId;

    return (action, creatureData);
  }
}
