// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-creatures/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { VoxelCoord, ObjectProperties, Action, SimTable, ElementType } from "@tenet-utils/src/Types.sol";
import { uint256ToNegativeInt256 } from "@tenet-utils/src/TypeUtils.sol";

import { Creature, CreatureData } from "@tenet-creatures/src/codegen/tables/Creature.sol";

import { getObjectProperties } from "@tenet-base-world/src/CallUtils.sol";
import { positionDataToVoxelCoord, getEntityIdFromObjectEntityId, getVoxelCoord, getObjectType } from "@tenet-base-world/src/Utils.sol";

import { entityIsCreature } from "@tenet-creatures/src/Utils.sol";
import { CreatureMove, CreatureMoveData } from "@tenet-creatures/src/Types.sol";
import { NUM_BLOCKS_FAINTED } from "@tenet-creatures/src/Constants.sol";

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
    bytes32 neighbourEntityId,
    bytes32 centerObjectEntityId
  ) public returns (bool, Action[] memory) {
    // PokemonData memory pokemonData = Pokemon.get(callerAddress, interactEntity);
    // console.log("pokemon onNewNeighbour");
    // console.logBytes32(interactEntity);
    // if (!entityIsPokemon(callerAddress, neighbourEntityId)) {
    //   return (changedEntity, entityData);
    // }
    // BodySimData memory entitySimData = getEntitySimData(interactEntity);
    // BodySimData memory neighbourEntitySimData = getEntitySimData(neighbourEntityId);
    // if (
    //   entitySimData.actionData.actionType == ElementType.None &&
    //   neighbourEntitySimData.actionData.actionType != ElementType.None
    // ) {
    //   // TODO: check actionEntity matches? We need this if we want multiple pokemon to be able to fight at the same time
    //   changedEntity = true;
    // }
    // pokemonData = endOfFightLogic(pokemonData, entitySimData);
    // Pokemon.set(callerAddress, interactEntity, pokemonData);
    // if (pokemonData.isFainted && block.number >= pokemonData.lastFaintedBlock + NUM_BLOCKS_FAINTED) {
    //   pokemonData.isFainted = false;
    //   Pokemon.set(callerAddress, interactEntity, pokemonData);
    // }
    // console.logBool(changedEntity);
    // return (changedEntity, entityData);
  }

  function defaultEventHandler(
    address worldAddress,
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {}

  function moveEventHandler(
    address worldAddress,
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds,
    CreatureMove creatureMove
  ) public returns (Action[] memory) {}

  // function runInteraction(
  //   address callerAddress,
  //   bytes32 interactEntity,
  //   bytes32[] memory neighbourEntityIds,
  //   VoxelCoord memory centerPosition,
  //   bytes32[] memory childEntityIds,
  //   bytes32 parentEntity,
  //   CreatureMove CreatureMove
  // ) internal returns (bool changedEntity, bytes memory entityData) {
  //   changedEntity = false;

  //   console.log("pokemon runInteraction");
  //   console.logBytes32(interactEntity);

  //   BodySimData memory entitySimData = getEntitySimData(interactEntity);
  //   PokemonData memory pokemonData = Pokemon.get(callerAddress, interactEntity);

  //   if (entitySimData.ElementType == ElementType.None) {
  //     CAEventData[] memory allCAEventData = new CAEventData[](1);
  //     VoxelEntity memory entity = VoxelEntity({ scale: 1, entityId: caEntityToEntity(interactEntity) });
  //     VoxelCoord memory coord = getCAEntityPositionStrict(IStore(_world()), interactEntity);

  //     SimEventData memory setObjectTypeSimEvent = SimEventData({
  //       senderTable: SimTable.Object,
  //       senderValue: abi.encode(entitySimData.ElementType),
  //       targetEntity: entity,
  //       targetCoord: coord,
  //       targetTable: SimTable.Object,
  //       targetValue: abi.encode(pokemonData.pokemonType)
  //     });
  //     console.log("setObjectTypeSimEvent");
  //     allCAEventData[0] = CAEventData({
  //       eventType: CAEventType.SimEvent,
  //       eventData: abi.encode(setObjectTypeSimEvent)
  //     });
  //     entityData = abi.encode(allCAEventData);
  //     return (changedEntity, entityData);
  //   }

  //   entityData = stopEvent(interactEntity, centerPosition, entitySimData);
  //   if (entityData.length > 0) {
  //     console.log("stopping");
  //     return (false, entityData);
  //   }

  //   pokemonData = resetStaleFightingCAEntity(neighbourEntityIds, pokemonData);

  //   if (CreatureMove == CreatureMove.None) {
  //     console.log("default interaction");
  //     return runDefaultInteraction(callerAddress, interactEntity, entitySimData, pokemonData);
  //   }

  //   CAEventData[] memory allCAEventData = new CAEventData[](neighbourEntityIds.length);
  //   bool hasEvent = false;

  //   pokemonData = endOfFightLogic(pokemonData, entitySimData);
  //   Pokemon.set(callerAddress, interactEntity, pokemonData);

  //   if (pokemonData.isFainted && block.number >= pokemonData.lastFaintedBlock + NUM_BLOCKS_FAINTED) {
  //     pokemonData.isFainted = false;
  //     Pokemon.set(callerAddress, interactEntity, pokemonData);
  //   }

  //   // Check if neighbour is pokemon and run move
  //   console.log("try fight");
  //   bool foundPokemon = false;
  //   for (uint256 i = 0; i < neighbourEntityIds.length; i++) {
  //     if (uint256(neighbourEntityIds[i]) == 0) {
  //       continue;
  //     }

  //     if (!entityIsPokemon(callerAddress, neighbourEntityIds[i])) {
  //       continue;
  //     }
  //     if (foundPokemon) {
  //       revert("Pokemon can't fight more than one pokemon at a time");
  //     }
  //     // TODO: handle non-pokemon interaction
  //     // if (!getCAEntityIsAgent(REGISTRY_ADDRESS, neighbourEntityIds[i])) {
  //     //   continue;
  //     // }

  //     foundPokemon = true;
  //     (allCAEventData[i], pokemonData) = runPokemonMove(
  //       callerAddress,
  //       interactEntity,
  //       neighbourEntityIds[i],
  //       pokemonData,
  //       entitySimData,
  //       CreatureMove
  //     );
  //     Pokemon.set(callerAddress, interactEntity, pokemonData);
  //     if (allCAEventData[i].eventType != CAEventType.None) {
  //       hasEvent = true;
  //     }
  //   }

  //   if (hasEvent) {
  //     entityData = abi.encode(allCAEventData);
  //   }

  //   // Note: we don't need to set changedEntity to true, because we don't need another event

  //   return (changedEntity, entityData);
  // }

  // function resetStaleFightingCAEntity(
  //   bytes32[] memory neighbourEntityIds,
  //   PokemonData memory pokemonData
  // ) internal returns (PokemonData memory) {
  //   if (pokemonData.fightingCAEntity == bytes32(0)) {
  //     return pokemonData;
  //   }
  //   bool foundFightingEntity = false;
  //   for (uint256 i = 0; i < neighbourEntityIds.length; i++) {
  //     if (neighbourEntityIds[i] == pokemonData.fightingCAEntity) {
  //       foundFightingEntity = true;
  //       break;
  //     }
  //   }
  //   if (!foundFightingEntity) {
  //     pokemonData.fightingCAEntity = bytes32(0);
  //   }
  //   return pokemonData;
  // }

  // function runDefaultInteraction(
  //   address callerAddress,
  //   bytes32 interactEntity,
  //   BodySimData memory entitySimData,
  //   PokemonData memory pokemonData
  // ) internal returns (bool changedEntity, bytes memory entityData) {
  //   pokemonData = endOfFightLogic(pokemonData, entitySimData);
  //   Pokemon.set(callerAddress, interactEntity, pokemonData);

  //   if (pokemonData.isFainted && block.number >= pokemonData.lastFaintedBlock + NUM_BLOCKS_FAINTED) {
  //     pokemonData.isFainted = false;
  //     Pokemon.set(callerAddress, interactEntity, pokemonData);
  //   }

  //   return (changedEntity, entityData);
  // }

  // function endOfFightLogic(
  //   PokemonData memory pokemonData,
  //   BodySimData memory entitySimData
  // ) internal returns (PokemonData memory) {
  //   if (pokemonData.fightingCAEntity != bytes32(0)) {
  //     BodySimData memory fightingEntitySimData = getEntitySimData(pokemonData.fightingCAEntity);
  //     if (
  //       (entitySimData.health == 0 || entitySimData.stamina == 0) ||
  //       (fightingEntitySimData.health == 0 || fightingEntitySimData.stamina == 0)
  //     ) {
  //       if (
  //         (entitySimData.health == 0 || entitySimData.stamina == 0) &&
  //         (fightingEntitySimData.health == 0 || fightingEntitySimData.stamina == 0)
  //       ) {
  //         // both died, no winner
  //         pokemonData.isFainted = true;
  //         pokemonData.lastFaintedBlock = block.number;
  //       } else if (entitySimData.health == 0 || entitySimData.stamina == 0) {
  //         // entity died
  //         pokemonData.isFainted = true;
  //         pokemonData.lastFaintedBlock = block.number;
  //         pokemonData.numLosses += 1;
  //       } else {
  //         // fighting entity died
  //         pokemonData.numWins += 1;
  //       }
  //       pokemonData.fightingCAEntity = bytes32(0);
  //     }
  //   }
  //   return pokemonData;
  // }

  // function runPokemonMove(
  //   address callerAddress,
  //   bytes32 interactEntity,
  //   bytes32 neighbourEntity,
  //   PokemonData memory pokemonData,
  //   BodySimData memory entitySimData,
  //   CreatureMove CreatureMove
  // ) internal returns (CAEventData memory caEventData, PokemonData memory) {
  //   console.log("runPokemonMove");
  //   // VoxelCoord memory currentVelocity = abi.decode(entitySimData.velocity, (VoxelCoord));
  //   // if (!isZeroCoord(currentVelocity)) {
  //   //   return (caEventData, pokemonData);
  //   // }

  //   if (pokemonData.isFainted || block.number < pokemonData.lastFaintedBlock + NUM_BLOCKS_FAINTED) {
  //     return (caEventData, pokemonData);
  //   }

  //   BodySimData memory neighbourEntitySimData = getEntitySimData(neighbourEntity);

  //   if (
  //     entitySimData.health == 0 ||
  //     entitySimData.stamina == 0 ||
  //     neighbourEntitySimData.health == 0 ||
  //     neighbourEntitySimData.stamina == 0
  //   ) {
  //     return (caEventData, pokemonData);
  //   }

  //   if (entitySimData.actionData.actionType != ElementType.None) {
  //     return (caEventData, pokemonData);
  //   }

  //   CreatureMove memory CreatureMove = getMoveData(CreatureMove);
  //   uint staminaAmount = uint(CreatureMove.stamina);
  //   bool isAttack = CreatureMove.damage > 0;

  //   if (entitySimData.stamina < staminaAmount) {
  //     return (caEventData, pokemonData);
  //   }

  //   VoxelEntity memory targetEntity = isAttack
  //     ? VoxelEntity({ scale: 1, entityId: caEntityToEntity(neighbourEntity) })
  //     : VoxelEntity({ scale: 1, entityId: caEntityToEntity(interactEntity) });
  //   VoxelCoord memory targetCoord = isAttack
  //     ? getCAEntityPositionStrict(IStore(_world()), neighbourEntity)
  //     : getCAEntityPositionStrict(IStore(_world()), interactEntity);

  //   console.log("picked move");

  //   SimEventData memory moveEventData = SimEventData({
  //     senderTable: SimTable.Stamina,
  //     senderValue: abi.encode(uint256ToNegativeInt256(staminaAmount)),
  //     targetEntity: targetEntity,
  //     targetCoord: targetCoord,
  //     targetTable: SimTable.Action,
  //     targetValue: abi.encode(CreatureMove.moveType)
  //   });
  //   caEventData = CAEventData({ eventType: CAEventType.SimEvent, eventData: abi.encode(moveEventData) });

  //   require(
  //     pokemonData.fightingCAEntity == bytes32(0) || pokemonData.fightingCAEntity == neighbourEntity,
  //     "Pokemon is already fighting"
  //   );
  //   pokemonData.fightingCAEntity = neighbourEntity;

  //   return (caEventData, pokemonData);
  // }
}
