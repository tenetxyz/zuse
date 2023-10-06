// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { calculateBlockDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { BlockDirection, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { BlockDirection, BodyPhysicsData, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { Soil } from "@tenet-pokemon-extension/src/codegen/tables/Soil.sol";
import { Plant } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { PlantStage } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { Pokemon, PokemonData, PokemonMove } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { entityIsSoil, entityIsPlant, entityIsPokemon } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { getVoxelBodyPhysicsFromCaller, transferEnergy } from "@tenet-level1-ca/src/Utils.sol";
import { isZeroCoord, voxelCoordsAreEqual } from "@tenet-utils/src/VoxelCoordUtils.sol";
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
    (changedEntity, entityData, pokemonData) = IWorld(_world()).pokemon_PokemonFightSyst_runBattleLogic(
      callerAddress,
      interactEntity,
      neighbourEntityId,
      pokemonData
    );
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

    BodyPhysicsData memory entityBodyPhysics = getVoxelBodyPhysicsFromCaller(interactEntity);
    PokemonData memory pokemonData = Pokemon.get(callerAddress, interactEntity);

    bool foundPlant = false;

    // Energy replenish if neighbour is food
    for (uint256 i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }

      if (!entityIsPlant(callerAddress, neighbourEntityIds[i])) {
        continue;
      }
      foundPlant = true;

      PlantStage plantStage = Plant.getStage(callerAddress, neighbourEntityIds[i]);
      if (plantStage != PlantStage.Flower) {
        continue;
      }

      pokemonData = replenishEnergy(
        callerAddress,
        interactEntity,
        neighbourEntityIds[i],
        pokemonData,
        entityBodyPhysics
      );
      Pokemon.set(callerAddress, interactEntity, pokemonData);
      break; // Only take from one plant
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
      if (foundPlant) {
        revert("Pokemon can't fight and eat at the same time");
      }
      if (foundPokemon) {
        revert("Pokemon can't fight more than one pokemon at a time");
      }

      foundPokemon = true;
      (entityData, pokemonData) = runPokemonMove(
        callerAddress,
        interactEntity,
        neighbourEntityIds[i],
        pokemonData,
        entityBodyPhysics,
        pokemonMove
      );
      Pokemon.set(callerAddress, interactEntity, pokemonData);
      break;
    }

    // Note: we don't need to set changedEntity to true, because we don't need another event

    return (changedEntity, entityData);
  }

  function runPokemonMove(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntity,
    PokemonData memory pokemonData,
    BodyPhysicsData memory entityBodyPhysics,
    PokemonMove pokemonMove
  ) internal returns (bytes memory entityData, PokemonData memory) {
    VoxelCoord memory currentVelocity = abi.decode(entityBodyPhysics.velocity, (VoxelCoord));
    if (!isZeroCoord(currentVelocity)) {
      return (entityData, pokemonData);
    }

    if (pokemonData.health == 0 && block.number < pokemonData.lastUpdatedBlock + NUM_BLOCKS_FAINTED) {
      return (entityData, pokemonData);
    }

    pokemonData.move = pokemonMove;
    pokemonData.round += 1;
    pokemonData.lostStamina += uint(IWorld(_world()).pokemon_PokemonFightSyst_getStaminaCost(pokemonMove));

    (, entityData, pokemonData) = IWorld(_world()).pokemon_PokemonFightSyst_runBattleLogic(
      callerAddress,
      interactEntity,
      neighbourEntity,
      pokemonData
    );

    return (entityData, pokemonData);
  }

  function replenishEnergy(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntity,
    PokemonData memory pokemonData,
    BodyPhysicsData memory entityBodyPhysics
  ) internal returns (PokemonData memory) {
    uint256 lastEnergy = pokemonData.lastEnergy;
    if (lastEnergy == entityBodyPhysics.energy) {
      return pokemonData;
    }

    if (
      pokemonData.round == 0 ||
      (pokemonData.round == -1 && block.number >= pokemonData.lastUpdatedBlock + NUM_BLOCKS_FAINTED)
    ) {
      pokemonData.lastEnergy = entityBodyPhysics.energy;
      pokemonData.lastUpdatedBlock = block.number;
      // Allocate percentages to Health and Stamina
      pokemonData.health = (pokemonData.lastEnergy * 40) / 100; // 40% to Health
      pokemonData.stamina = (pokemonData.lastEnergy * 30) / 100; // 30% to Stamina
      pokemonData.round = 0;
    }

    return pokemonData;
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
