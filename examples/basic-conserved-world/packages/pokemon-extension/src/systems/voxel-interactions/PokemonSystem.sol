// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { calculateBlockDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { VoxelEntity, BlockDirection, VoxelCoord, BodySimData, CAEventData, CAEventType, ObjectType, SimEventData, SimTable } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { Soil } from "@tenet-pokemon-extension/src/codegen/tables/Soil.sol";
import { Plant } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { PlantStage } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { Pokemon, PokemonData, PokemonMove } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { entityIsSoil, entityIsPlant, entityIsPokemon } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict, caEntityToEntity } from "@tenet-base-ca/src/Utils.sol";
import { getEntitySimData, transferEnergy } from "@tenet-level1-ca/src/Utils.sol";
import { isZeroCoord, voxelCoordsAreEqual } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { MoveData } from "@tenet-pokemon-extension/src/Types.sol";
import { console } from "forge-std/console.sol";

uint256 constant NUM_BLOCKS_FAINTED = 50;

contract PokemonSystem is System {
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
    (changedEntity, entityData, pokemonData) = IWorld(_world()).pokemon_PokemonFightSyst_runBattleLogic(
      callerAddress,
      interactEntity,
      neighbourEntityId,
      pokemonData
    );
    console.logBool(changedEntity);
    Pokemon.set(callerAddress, interactEntity, pokemonData);
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

    CAEventData[] memory allCAEventData = new CAEventData[](neighbourEntityIds.length + 1);

    bool hasEvent = false;

    if (entitySimData.objectType == ObjectType.None) {
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
      (allCAEventData[i + 1], pokemonData) = runPokemonMove(
        callerAddress,
        interactEntity,
        neighbourEntityIds[i],
        pokemonData,
        entitySimData,
        pokemonMove
      );
      Pokemon.set(callerAddress, interactEntity, pokemonData);
      if (allCAEventData[i + 1].eventType != CAEventType.None) {
        console.log("move event");
        hasEvent = true;
      }
      break;
    }

    if (hasEvent) {
      entityData = abi.encode(allCAEventData);
    }

    // Note: we don't need to set changedEntity to true, because we don't need another event

    return (changedEntity, entityData);
  }

  function runPokemonMove(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntity,
    PokemonData memory pokemonData,
    BodySimData memory entitySimData,
    PokemonMove pokemonMove
  ) internal returns (CAEventData memory caEventData, PokemonData memory) {
    VoxelCoord memory currentVelocity = abi.decode(entitySimData.velocity, (VoxelCoord));
    if (!isZeroCoord(currentVelocity)) {
      return (caEventData, pokemonData);
    }

    // if (entitySimData.health == 0 && block.number < pokemonData.lastUpdatedBlock + NUM_BLOCKS_FAINTED) {
    //   return (caEventData, pokemonData);
    // }

    if (entitySimData.actionData.actionType != ObjectType.None) {
      console.log("already got move");
      return (caEventData, pokemonData);
    }

    MoveData memory moveData = IWorld(_world()).pokemon_PokemonFightSyst_getMoveData(pokemonMove);
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
      senderValue: abi.encode(staminaAmount),
      targetEntity: targetEntity,
      targetCoord: targetCoord,
      targetTable: SimTable.Action,
      targetValue: abi.encode(moveData.moveType)
    });
    caEventData = CAEventData({ eventType: CAEventType.SimEvent, eventData: abi.encode(moveEventData) });

    // pokemonData.move = pokemonMove;
    // pokemonData.round += 1;
    // pokemonData.lostStamina += uint(IWorld(_world()).pokemon_PokemonFightSyst_getStaminaCost(pokemonMove));

    // (, entityData, pokemonData) = IWorld(_world()).pokemon_PokemonFightSyst_runBattleLogic(
    //   callerAddress,
    //   interactEntity,
    //   neighbourEntity,
    //   pokemonData
    // );

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
