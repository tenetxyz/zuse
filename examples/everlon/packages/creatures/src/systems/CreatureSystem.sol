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
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict, caEntityToEntity, getCAEntityIsAgent } from "@tenet-base-ca/src/Utils.sol";
import { getEntitySimData, stopEvent } from "@tenet-level1-ca/src/Utils.sol";
import { isZeroCoord, voxelCoordsAreEqual } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { MoveData, PokemonMove } from "@tenet-pokemon-extension/src/Types.sol";
import { console } from "forge-std/console.sol";
import { REGISTRY_ADDRESS } from "@tenet-level1-ca/src/Constants.sol";

import { NUM_BLOCKS_FAINTED } from "@tenet-pokemon-extension/src/Constants.sol";

contract CreatureSystem is System {
  function getMovesData() internal pure returns (MoveData[] memory) {
    MoveData[] memory movesData = new MoveData[](19); // the first value is for PokemonMove.None
    movesData[uint(PokemonMove.Ember)] = MoveData(1000, 6, 0, ObjectType.Fire);
    movesData[uint(PokemonMove.FlameBurst)] = MoveData(5000, 27, 0, ObjectType.Fire);
    movesData[uint(PokemonMove.InfernoClash)] = MoveData(20000, 90, 0, ObjectType.Fire);
    movesData[uint(PokemonMove.SmokeScreen)] = MoveData(3000, 0, 19, ObjectType.Fire);
    movesData[uint(PokemonMove.FireShield)] = MoveData(7000, 0, 38, ObjectType.Fire);
    movesData[uint(PokemonMove.PyroBarrier)] = MoveData(12000, 0, 54, ObjectType.Fire);

    movesData[uint(PokemonMove.WaterGun)] = MoveData(1000, 6, 0, ObjectType.Water);
    movesData[uint(PokemonMove.HydroPump)] = MoveData(5000, 27, 0, ObjectType.Water);
    movesData[uint(PokemonMove.TidalCrash)] = MoveData(20000, 90, 0, ObjectType.Water);
    movesData[uint(PokemonMove.Bubble)] = MoveData(3000, 0, 19, ObjectType.Water);
    movesData[uint(PokemonMove.AquaRing)] = MoveData(7000, 0, 38, ObjectType.Water);
    movesData[uint(PokemonMove.MistVeil)] = MoveData(12000, 0, 54, ObjectType.Water);

    movesData[uint(PokemonMove.VineWhip)] = MoveData(1000, 6, 0, ObjectType.Grass);
    movesData[uint(PokemonMove.SolarBeam)] = MoveData(5000, 27, 0, ObjectType.Grass);
    movesData[uint(PokemonMove.ThornBurst)] = MoveData(20000, 90, 0, ObjectType.Grass);
    movesData[uint(PokemonMove.LeechSeed)] = MoveData(3000, 0, 19, ObjectType.Grass);
    movesData[uint(PokemonMove.Synthesis)] = MoveData(7000, 0, 38, ObjectType.Grass);
    movesData[uint(PokemonMove.VerdantGuard)] = MoveData(20000, 90, 0, ObjectType.Grass);
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
      centerPosition,
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
    VoxelCoord memory centerPosition,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity,
    PokemonMove pokemonMove
  ) internal returns (bool changedEntity, bytes memory entityData) {
    changedEntity = false;

    console.log("pokemon runInteraction");
    console.logBytes32(interactEntity);

    BodySimData memory entitySimData = getEntitySimData(interactEntity);
    PokemonData memory pokemonData = Pokemon.get(callerAddress, interactEntity);

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

    entityData = stopEvent(interactEntity, centerPosition, entitySimData);
    if (entityData.length > 0) {
      console.log("stopping");
      return (false, entityData);
    }

    pokemonData = resetStaleFightingCAEntity(neighbourEntityIds, pokemonData);

    if (pokemonMove == PokemonMove.None) {
      console.log("default interaction");
      return runDefaultInteraction(callerAddress, interactEntity, entitySimData, pokemonData);
    }

    CAEventData[] memory allCAEventData = new CAEventData[](neighbourEntityIds.length);
    bool hasEvent = false;

    pokemonData = endOfFightLogic(pokemonData, entitySimData);
    Pokemon.set(callerAddress, interactEntity, pokemonData);

    if (pokemonData.isFainted && block.number >= pokemonData.lastFaintedBlock + NUM_BLOCKS_FAINTED) {
      pokemonData.isFainted = false;
      Pokemon.set(callerAddress, interactEntity, pokemonData);
    }

    // Check if neighbour is pokemon and run move
    console.log("try fight");
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
      // TODO: handle non-pokemon interaction
      // if (!getCAEntityIsAgent(REGISTRY_ADDRESS, neighbourEntityIds[i])) {
      //   continue;
      // }

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

  function resetStaleFightingCAEntity(
    bytes32[] memory neighbourEntityIds,
    PokemonData memory pokemonData
  ) internal returns (PokemonData memory) {
    if (pokemonData.fightingCAEntity == bytes32(0)) {
      return pokemonData;
    }
    bool foundFightingEntity = false;
    for (uint256 i = 0; i < neighbourEntityIds.length; i++) {
      if (neighbourEntityIds[i] == pokemonData.fightingCAEntity) {
        foundFightingEntity = true;
        break;
      }
    }
    if (!foundFightingEntity) {
      pokemonData.fightingCAEntity = bytes32(0);
    }
    return pokemonData;
  }

  function runDefaultInteraction(
    address callerAddress,
    bytes32 interactEntity,
    BodySimData memory entitySimData,
    PokemonData memory pokemonData
  ) internal returns (bool changedEntity, bytes memory entityData) {
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
          pokemonData.lastFaintedBlock = block.number;
        } else if (entitySimData.health == 0 || entitySimData.stamina == 0) {
          // entity died
          pokemonData.isFainted = true;
          pokemonData.lastFaintedBlock = block.number;
          pokemonData.numLosses += 1;
        } else {
          // fighting entity died
          pokemonData.numWins += 1;
        }
        pokemonData.fightingCAEntity = bytes32(0);
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
    console.log("runPokemonMove");
    // VoxelCoord memory currentVelocity = abi.decode(entitySimData.velocity, (VoxelCoord));
    // if (!isZeroCoord(currentVelocity)) {
    //   return (caEventData, pokemonData);
    // }

    if (pokemonData.isFainted || block.number < pokemonData.lastFaintedBlock + NUM_BLOCKS_FAINTED) {
      return (caEventData, pokemonData);
    }

    BodySimData memory neighbourEntitySimData = getEntitySimData(neighbourEntity);

    if (
      entitySimData.health == 0 ||
      entitySimData.stamina == 0 ||
      neighbourEntitySimData.health == 0 ||
      neighbourEntitySimData.stamina == 0
    ) {
      return (caEventData, pokemonData);
    }

    if (entitySimData.actionData.actionType != ObjectType.None) {
      return (caEventData, pokemonData);
    }

    MoveData memory moveData = getMoveData(pokemonMove);
    uint staminaAmount = uint(moveData.stamina);
    bool isAttack = moveData.damage > 0;

    if (entitySimData.stamina < staminaAmount) {
      return (caEventData, pokemonData);
    }

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
