// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { calculateBlockDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { VoxelEntity, BlockDirection, VoxelCoord, BodySimData, CAEventData, CAEventType, ObjectType, SimEventData, SimTable } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { uint256ToNegativeInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { PlantStage } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { Pokemon, PokemonData } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { entityIsSoil, entityIsPlant, entityIsPokemon } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict, caEntityToEntity } from "@tenet-base-ca/src/Utils.sol";
import { getEntitySimData } from "@tenet-level1-ca/src/Utils.sol";
import { isZeroCoord, voxelCoordsAreEqual } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { MoveData, PokemonMove } from "@tenet-pokemon-extension/src/Types.sol";
import { console } from "forge-std/console.sol";

import { NUM_BLOCKS_FAINTED } from "@tenet-pokemon-extension/src/Constants.sol";

contract PokemonSystem is System {
  function getMovesData() internal pure returns (MoveData[] memory) {
    MoveData[] memory movesData = new MoveData[](13); // the first value is for PokemonMove.None
    movesData[uint(PokemonMove.Ember)] = MoveData(10, 20, 0, ObjectType.Fire);
    movesData[uint(PokemonMove.FlameBurst)] = MoveData(20, 40, 0, ObjectType.Fire);
    movesData[uint(PokemonMove.SmokeScreen)] = MoveData(5, 0, 10, ObjectType.Fire);
    movesData[uint(PokemonMove.FireShield)] = MoveData(15, 0, 30, ObjectType.Fire);

    movesData[uint(PokemonMove.WaterGun)] = MoveData(10, 20, 0, ObjectType.Water);
    movesData[uint(PokemonMove.HydroPump)] = MoveData(20, 40, 0, ObjectType.Water);
    movesData[uint(PokemonMove.Bubble)] = MoveData(5, 0, 10, ObjectType.Water);
    movesData[uint(PokemonMove.AquaRing)] = MoveData(15, 0, 30, ObjectType.Water);

    movesData[uint(PokemonMove.VineWhip)] = MoveData(10, 20, 0, ObjectType.Grass);
    movesData[uint(PokemonMove.SolarBeam)] = MoveData(20, 40, 0, ObjectType.Grass);
    movesData[uint(PokemonMove.LeechSeed)] = MoveData(5, 0, 10, ObjectType.Grass);
    movesData[uint(PokemonMove.Synthesis)] = MoveData(15, 0, 30, ObjectType.Grass);
    return movesData;
  }

  function getMoveData(PokemonMove move) internal pure returns (MoveData memory) {
    MoveData[] memory movesData = getMovesData();
    return movesData[uint(move)];
  }

  function eventHandler(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity,
    PokemonMove pokemonMove
  ) internal returns (bool changedCenterEntityId, bytes memory centerEntityData) {
    VoxelCoord memory centerPosition = getCAEntityPositionStrict(IStore(_world()), centerEntityId);

    BlockDirection[] memory neighbourEntityDirections = new BlockDirection[](neighbourEntityIds.length);
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 neighbourEntityId = neighbourEntityIds[i];
      if (uint256(neighbourEntityId) == 0) {
        neighbourEntityDirections[i] = BlockDirection.None;
        continue;
      }

      BlockDirection centerBlockDirection = calculateBlockDirection(
        getCAEntityPositionStrict(IStore(_world()), neighbourEntityId),
        centerPosition
      );
      neighbourEntityDirections[i] = centerBlockDirection;
    }
    (changedCenterEntityId, centerEntityData) = runInteraction(
      callerAddress,
      centerEntityId,
      neighbourEntityIds,
      neighbourEntityDirections,
      childEntityIds,
      parentEntity,
      pokemonMove
    );

    return (changedCenterEntityId, centerEntityData);
  }

  function neighbourEventHandler(
    address callerAddress,
    bytes32 neighbourEntityId,
    bytes32 centerEntityId,
    PokemonMove pokemonMove
  ) internal returns (bool changedNeighbourEntityId, bytes memory neighbourEntityData) {
    BlockDirection centerBlockDirection = calculateBlockDirection(
      getCAEntityPositionStrict(IStore(_world()), centerEntityId),
      getCAEntityPositionStrict(IStore(_world()), neighbourEntityId)
    );

    (changedNeighbourEntityId, neighbourEntityData) = onNewNeighbour(
      callerAddress,
      neighbourEntityId,
      centerEntityId,
      centerBlockDirection,
      pokemonMove
    );

    return (changedNeighbourEntityId, neighbourEntityData);
  }

  function onNewNeighbour(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntityId,
    BlockDirection neighbourBlockDirection,
    PokemonMove pokemonMove
  ) internal returns (bool changedEntity, bytes memory entityData) {
    PokemonData memory pokemonData = Pokemon.get(callerAddress, interactEntity);
    console.log("pokemon onNewNeighbour");
    console.logBytes32(interactEntity);
    if (!entityIsPokemon(callerAddress, neighbourEntityId)) {
      return (changedEntity, entityData);
    }

    BodySimData memory entitySimData = getEntitySimData(interactEntity);
    BodySimData memory neighbourEntitySimData = getEntitySimData(neighbourEntityId);

    if (
      entitySimData.actionData.actionType == ObjectType.None &&
      neighbourEntitySimData.actionData.actionType != ObjectType.None
    ) {
      // TODO: check actionEntity matches? We need this if we want multiple pokemon to be able to fight at the same time
      changedEntity = true;
    }

    pokemonData = endOfFightLogic(pokemonData, entitySimData);
    Pokemon.set(callerAddress, interactEntity, pokemonData);

    if (pokemonData.isFainted && block.number >= pokemonData.lastFaintedBlock + NUM_BLOCKS_FAINTED) {
      pokemonData.isFainted = false;
      Pokemon.set(callerAddress, interactEntity, pokemonData);
    }

    console.logBool(changedEntity);
    return (changedEntity, entityData);
  }

  function runInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity,
    PokemonMove pokemonMove
  ) internal returns (bool changedEntity, bytes memory entityData) {
    changedEntity = false;

    console.log("pokemon runInteraction");
    console.logBytes32(interactEntity);

    BodySimData memory entitySimData = getEntitySimData(interactEntity);
    PokemonData memory pokemonData = Pokemon.get(callerAddress, interactEntity);

    if (pokemonMove == PokemonMove.None) {
      return runDefaultInteraction(callerAddress, interactEntity, entitySimData, pokemonData);
    }

    CAEventData[] memory allCAEventData = new CAEventData[](neighbourEntityIds.length);
    bool hasEvent = false;

    // Check if neighbour is pokemon and run move
    bool foundPokemon = false;
    for (uint256 i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }

      if (!entityIsPokemon(callerAddress, neighbourEntityIds[i])) {
        continue;
      }
      if (foundPokemon) {
        revert("Pokemon can't fight more than one pokemon at a time");
      }

      foundPokemon = true;
      (allCAEventData[i], pokemonData) = runPokemonMove(
        callerAddress,
        interactEntity,
        neighbourEntityIds[i],
        pokemonData,
        entitySimData,
        pokemonMove
      );
      Pokemon.set(callerAddress, interactEntity, pokemonData);
      if (allCAEventData[i].eventType != CAEventType.None) {
        hasEvent = true;
      }
    }

    if (hasEvent) {
      entityData = abi.encode(allCAEventData);
    }

    // Note: we don't need to set changedEntity to true, because we don't need another event

    return (changedEntity, entityData);
  }

  function runDefaultInteraction(
    address callerAddress,
    bytes32 interactEntity,
    BodySimData memory entitySimData,
    PokemonData memory pokemonData
  ) internal returns (bool changedEntity, bytes memory entityData) {
    if (entitySimData.objectType == ObjectType.None) {
      CAEventData[] memory allCAEventData = new CAEventData[](1);
      VoxelEntity memory entity = VoxelEntity({ scale: 1, entityId: caEntityToEntity(interactEntity) });
      VoxelCoord memory coord = getCAEntityPositionStrict(IStore(_world()), interactEntity);

      SimEventData memory setObjectTypeSimEvent = SimEventData({
        senderTable: SimTable.Object,
        senderValue: abi.encode(entitySimData.objectType),
        targetEntity: entity,
        targetCoord: coord,
        targetTable: SimTable.Object,
        targetValue: abi.encode(pokemonData.pokemonType)
      });
      console.log("setObjectTypeSimEvent");
      allCAEventData[0] = CAEventData({
        eventType: CAEventType.SimEvent,
        eventData: abi.encode(setObjectTypeSimEvent)
      });
      entityData = abi.encode(allCAEventData);
      return (changedEntity, entityData);
    }

    pokemonData = endOfFightLogic(pokemonData, entitySimData);
    Pokemon.set(callerAddress, interactEntity, pokemonData);

    if (pokemonData.isFainted && block.number >= pokemonData.lastFaintedBlock + NUM_BLOCKS_FAINTED) {
      pokemonData.isFainted = false;
      Pokemon.set(callerAddress, interactEntity, pokemonData);
    }

    return (changedEntity, entityData);
  }

  function endOfFightLogic(
    PokemonData memory pokemonData,
    BodySimData memory entitySimData
  ) internal returns (PokemonData memory) {
    if (pokemonData.fightingCAEntity != bytes32(0)) {
      BodySimData memory fightingEntitySimData = getEntitySimData(pokemonData.fightingCAEntity);
      if (
        (entitySimData.health == 0 || entitySimData.stamina == 0) ||
        (fightingEntitySimData.health == 0 || fightingEntitySimData.stamina == 0)
      ) {
        if (
          (entitySimData.health == 0 || entitySimData.stamina == 0) &&
          (fightingEntitySimData.health == 0 || fightingEntitySimData.stamina == 0)
        ) {
          // both died, no winner
          pokemonData.isFainted = true;
        } else if (entitySimData.health == 0 || entitySimData.stamina == 0) {
          // entity died
          pokemonData.isFainted = true;
          pokemonData.numLosses += 1;
        } else {
          // fighting entity died
          pokemonData.numWins += 1;
        }
        pokemonData.fightingCAEntity = bytes32(0);
        pokemonData.lastFaintedBlock = block.number;
      }
    }
    return pokemonData;
  }

  function runPokemonMove(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntity,
    PokemonData memory pokemonData,
    BodySimData memory entitySimData,
    PokemonMove pokemonMove
  ) internal returns (CAEventData memory caEventData, PokemonData memory) {
    // VoxelCoord memory currentVelocity = abi.decode(entitySimData.velocity, (VoxelCoord));
    // if (!isZeroCoord(currentVelocity)) {
    //   return (caEventData, pokemonData);
    // }

    pokemonData = endOfFightLogic(pokemonData, entitySimData);

    if (pokemonData.isFainted && block.number >= pokemonData.lastFaintedBlock + NUM_BLOCKS_FAINTED) {
      pokemonData.isFainted = false;
    }

    if (pokemonData.isFainted || block.number < pokemonData.lastFaintedBlock + NUM_BLOCKS_FAINTED) {
      return (caEventData, pokemonData);
    }

    if (entitySimData.health == 0 || entitySimData.stamina == 0) {
      return (caEventData, pokemonData);
    }

    if (entitySimData.actionData.actionType != ObjectType.None) {
      return (caEventData, pokemonData);
    }

    MoveData memory moveData = getMoveData(pokemonMove);
    uint staminaAmount = uint(moveData.stamina);
    bool isAttack = moveData.damage > 0;

    VoxelEntity memory targetEntity = isAttack
      ? VoxelEntity({ scale: 1, entityId: caEntityToEntity(neighbourEntity) })
      : VoxelEntity({ scale: 1, entityId: caEntityToEntity(interactEntity) });
    VoxelCoord memory targetCoord = isAttack
      ? getCAEntityPositionStrict(IStore(_world()), neighbourEntity)
      : getCAEntityPositionStrict(IStore(_world()), interactEntity);

    console.log("picked move");

    SimEventData memory moveEventData = SimEventData({
      senderTable: SimTable.Stamina,
      senderValue: abi.encode(uint256ToNegativeInt256(staminaAmount)),
      targetEntity: targetEntity,
      targetCoord: targetCoord,
      targetTable: SimTable.Action,
      targetValue: abi.encode(moveData.moveType)
    });
    caEventData = CAEventData({ eventType: CAEventType.SimEvent, eventData: abi.encode(moveEventData) });

    require(
      pokemonData.fightingCAEntity == bytes32(0) || pokemonData.fightingCAEntity == neighbourEntity,
      "Pokemon is already fighting"
    );
    pokemonData.fightingCAEntity = neighbourEntity;

    return (caEventData, pokemonData);
  }

  function eventHandlerPokemon(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity,
    PokemonMove pokemonMove
  ) public returns (bool, bytes memory) {
    return eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity, pokemonMove);
  }

  function neighbourEventHandlerPokemon(
    address callerAddress,
    bytes32 neighbourEntityId,
    bytes32 centerEntityId,
    PokemonMove pokemonMove
  ) public returns (bool, bytes memory) {
    return neighbourEventHandler(callerAddress, neighbourEntityId, centerEntityId, pokemonMove);
  }
}
