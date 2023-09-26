// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { calculateBlockDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { BlockDirection, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { BlockDirection, BodyPhysicsData, CAEventData, CAEventType, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { EnergySource } from "@tenet-pokemon-extension/src/codegen/tables/EnergySource.sol";
import { Soil } from "@tenet-pokemon-extension/src/codegen/tables/Soil.sol";
import { Plant } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { PlantStage } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { Pokemon, PokemonData, PokemonMove } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { entityIsEnergySource, entityIsSoil, entityIsPlant, entityIsPokemon } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { getVoxelBodyPhysicsFromCaller, transferEnergy } from "@tenet-level1-ca/src/Utils.sol";
import { isZeroCoord, voxelCoordsAreEqual } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { console } from "forge-std/console.sol";

uint256 constant NUM_BLOCKS_FAINTED = 50;

contract PokemonSystem is System {
  function runCaseOne(
    address callerAddress,
    bytes32 centerEntityId,
    VoxelCoord memory centerPosition,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity,
    PokemonMove pokemonMove
  ) internal returns (bytes32, bytes memory) {
    bytes32 changedCenterEntityId = 0;
    bytes memory centerEntityData;
    if (entityShouldInteract(callerAddress, centerEntityId)) {
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
      (bool changedEntity, bytes memory entityData) = runInteraction(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        neighbourEntityDirections,
        childEntityIds,
        parentEntity,
        pokemonMove
      );
      centerEntityData = entityData;
      if (changedEntity) {
        changedCenterEntityId = centerEntityId;
      }
    }

    return (changedCenterEntityId, centerEntityData);
  }

  function onNewNeighbourWrapper(
    address callerAddress,
    bytes32 neighbourEntityId,
    bytes32 centerEntityId,
    VoxelCoord memory centerPosition,
    PokemonMove pokemonMove
  ) internal returns (bool, bytes memory) {
    BlockDirection centerBlockDirection = calculateBlockDirection(
      centerPosition,
      getCAEntityPositionStrict(IStore(_world()), neighbourEntityId)
    );

    return onNewNeighbour(callerAddress, neighbourEntityId, centerEntityId, centerBlockDirection, pokemonMove);
  }

  function runCaseTwo(
    address callerAddress,
    bytes32 centerEntityId,
    VoxelCoord memory centerPosition,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity,
    PokemonMove pokemonMove
  ) internal returns (bytes32[] memory, bytes[] memory) {
    bytes32[] memory changedEntityIds = new bytes32[](neighbourEntityIds.length);
    bytes[] memory neighbourEntitiesData = new bytes[](neighbourEntityIds.length);
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0 || !entityShouldInteract(callerAddress, neighbourEntityIds[i])) {
        changedEntityIds[i] = 0;
        continue;
      }

      (bool changedEntity, bytes memory entityData) = onNewNeighbourWrapper(
        callerAddress,
        neighbourEntityIds[i],
        centerEntityId,
        centerPosition,
        pokemonMove
      );
      neighbourEntitiesData[i] = entityData;

      if (changedEntity) {
        changedEntityIds[i] = neighbourEntityIds[i];
      } else {
        changedEntityIds[i] = 0;
      }
    }
    return (changedEntityIds, neighbourEntitiesData);
  }

  function eventHandler(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity,
    PokemonMove pokemonMove
  ) internal returns (bytes32, bytes32[] memory, bytes[] memory) {
    VoxelCoord memory centerPosition = getCAEntityPositionStrict(IStore(_world()), centerEntityId);

    // case one: center is the entity we care about, check neighbours to see if things need to change
    (bytes32 changedCenterEntityId, bytes memory centerEntityData) = runCaseOne(
      callerAddress,
      centerEntityId,
      centerPosition,
      neighbourEntityIds,
      childEntityIds,
      parentEntity,
      pokemonMove
    );

    // case two: neighbour is the entity we care about, check center to see if things need to change
    (bytes32[] memory changedEntityIds, bytes[] memory neighbourEntitiesData) = runCaseTwo(
      callerAddress,
      centerEntityId,
      centerPosition,
      neighbourEntityIds,
      childEntityIds,
      parentEntity,
      pokemonMove
    );

    bytes[] memory entityData = new bytes[](neighbourEntityIds.length + 1);
    entityData[0] = centerEntityData;
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      entityData[i + 1] = neighbourEntitiesData[i];
    }

    return (changedCenterEntityId, changedEntityIds, entityData);
  }

  function onNewNeighbour(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntityId,
    BlockDirection neighbourBlockDirection,
    PokemonMove pokemonMove
  ) internal returns (bool changedEntity, bytes memory entityData) {
    changedEntity = false;

    if (!entityIsPlant(callerAddress, neighbourEntityId)) {
      return (changedEntity, entityData);
    }

    PlantStage plantStage = Plant.getStage(callerAddress, neighbourEntityId);
    if (plantStage != PlantStage.Flower) {
      return (changedEntity, entityData);
    }

    BodyPhysicsData memory entityBodyPhysics = getVoxelBodyPhysicsFromCaller(interactEntity);
    PokemonData memory pokemonData = Pokemon.get(callerAddress, interactEntity);

    pokemonData = replenishEnergy(callerAddress, interactEntity, neighbourEntityId, pokemonData, entityBodyPhysics);
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

    // Energy replenish if neighbour is food
    for (uint256 i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }

      if (!entityIsPlant(callerAddress, neighbourEntityIds[i])) {
        continue;
      }

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
    }

    // Check if neighbour is pokemon and run move
    for (uint256 i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }

      if (!entityIsPokemon(callerAddress, neighbourEntityIds[i])) {
        continue;
      }

      // TODO: What if there's more than one?
      pokemonData = runPokemonMove(
        callerAddress,
        interactEntity,
        neighbourEntityIds[i],
        pokemonData,
        entityBodyPhysics,
        pokemonMove
      );
    }

    Pokemon.set(callerAddress, interactEntity, pokemonData);

    return (changedEntity, entityData);
  }

  function runPokemonMove(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntity,
    PokemonData memory pokemonData,
    BodyPhysicsData memory entityBodyPhysics,
    PokemonMove pokemonMove
  ) internal returns (PokemonData memory) {
    VoxelCoord memory currentVelocity = abi.decode(entityBodyPhysics.velocity, (VoxelCoord));
    if (!isZeroCoord(currentVelocity)) {
      return pokemonData;
    }

    if (pokemonData.health == 0 && block.number < pokemonData.lastUpdatedBlock + NUM_BLOCKS_FAINTED) {
      return pokemonData;
    }

    pokemonData.move = pokemonMove;
    pokemonData.lostStamina += 1;
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

    pokemonData.lastEnergy = entityBodyPhysics.energy;
    pokemonData.lastUpdatedBlock = block.number;

    if (pokemonData.health == 0 && block.number < pokemonData.lastUpdatedBlock + NUM_BLOCKS_FAINTED) {
      // Allocate percentages to Health and Stamina
      uint256 healthAllocation = (pokemonData.lastEnergy * 40) / 100; // 40% to Health
      uint256 staminaAllocation = (pokemonData.lastEnergy * 30) / 100; // 30% to Stamina
      pokemonData.health = healthAllocation;
      pokemonData.stamina = staminaAllocation;
    }
    return pokemonData;
  }

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view returns (bool) {
    return entityIsPokemon(callerAddress, entityId);
  }

  function eventHandlerPokemon(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity,
    PokemonMove pokemonMove
  ) public returns (bytes32, bytes32[] memory, bytes[] memory) {
    return eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity, pokemonMove);
  }
}
