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
import { Pokemon, PokemonData, PokemonMove, PokemonType } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { entityIsEnergySource, entityIsSoil, entityIsPlant, entityIsPokemon } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { getVoxelBodyPhysicsFromCaller, transferEnergy } from "@tenet-level1-ca/src/Utils.sol";
import { isZeroCoord, voxelCoordsAreEqual } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { console } from "forge-std/console.sol";

struct MoveData {
  uint8 stamina;
  uint8 damage;
  uint8 protection;
  PokemonType moveType;
}

contract PokemonFightSystem is System {
  function getMovesData() internal returns (MoveData[] memory) {
    MoveData[] memory movesData = new MoveData[](13); // the first value is for PokemonMove.None
    movesData[uint(PokemonMove.Ember)] = MoveData(10, 20, 0, PokemonType.Fire);
    movesData[uint(PokemonMove.FlameBurst)] = MoveData(20, 40, 0, PokemonType.Fire);
    movesData[uint(PokemonMove.SmokeScreen)] = MoveData(5, 0, 10, PokemonType.Fire);
    movesData[uint(PokemonMove.FireShield)] = MoveData(15, 0, 30, PokemonType.Fire);

    movesData[uint(PokemonMove.WaterGun)] = MoveData(10, 20, 0, PokemonType.Water);
    movesData[uint(PokemonMove.HydroPump)] = MoveData(20, 40, 0, PokemonType.Water);
    movesData[uint(PokemonMove.Bubble)] = MoveData(5, 0, 10, PokemonType.Water);
    movesData[uint(PokemonMove.AquaRing)] = MoveData(15, 0, 30, PokemonType.Water);

    movesData[uint(PokemonMove.VineWhip)] = MoveData(10, 20, 0, PokemonType.Grass);
    movesData[uint(PokemonMove.SolarBeam)] = MoveData(20, 40, 0, PokemonType.Grass);
    movesData[uint(PokemonMove.LeechSeed)] = MoveData(5, 0, 10, PokemonType.Grass);
    movesData[uint(PokemonMove.Synthesis)] = MoveData(15, 0, 30, PokemonType.Grass);
    return movesData;
  }

  function runBattleLogic(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntity
  ) public returns (bool changedEntity, bytes memory entityData) {
    console.log("runBattleLogic");
    if (!entityIsPokemon(callerAddress, neighbourEntity)) {
      console.log("not pokemon leave");
      return (changedEntity, entityData);
    }

    PokemonData memory pokemonData = Pokemon.get(callerAddress, interactEntity);
    PokemonData memory neighbourPokemonData = Pokemon.get(callerAddress, neighbourEntity);
    if (neighbourPokemonData.round == -1) {
      // This means battle is over
      // TODO: Run exit logic
      // set our own round to -1
      console.log("pokemon is dead");
      pokemonData.round = -1;
      return (changedEntity, entityData);
    }

    if (pokemonData.move == PokemonMove.None && neighbourPokemonData.move != PokemonMove.None) {
      console.log("my pokemon move is none");
      changedEntity = true;
      return (changedEntity, entityData);
    }

    if (pokemonData.move != PokemonMove.None && neighbourPokemonData.move != PokemonMove.None) {
      // This a new battle is in progress
      // TODO: check if round number is the same?
      console.log("both moves picked");

      if (pokemonData.round != neighbourPokemonData.round) {
        console.log("rounds are not the same");
        changedEntity = true;
        return (changedEntity, entityData);
      }

      // Calculate damage
      if (pokemonData.lostHealth < pokemonData.health) {
        console.log("calc damage");
        // Calculae damage
        MoveData[] memory movesData = getMovesData();
        MoveData memory myMoveData = movesData[uint(pokemonData.move)];
        MoveData memory opponentMoveData = movesData[uint(neighbourPokemonData.move)];
        if (opponentMoveData.damage > 0 && myMoveData.protection > 0) {
          uint256 damage = calculateDamage(myMoveData, opponentMoveData);
          uint256 protection = calculateProtection(myMoveData, opponentMoveData);
          pokemonData.lostHealth += (damage - protection);
        } else if (opponentMoveData.damage > 0) {
          uint256 damage = calculateDamage(myMoveData, opponentMoveData);
          pokemonData.lostHealth += damage;
        }

        // Update round number
        console.log("new lost health");
        console.logUint(pokemonData.lostHealth);
        console.logInt(pokemonData.round);

        // Save data
        Pokemon.set(callerAddress, interactEntity, pokemonData);

        changedEntity = true;
        // continue the fight to next round
      } else {
        console.log("pokemon dead after moves yo");
        // pokemon is dead
        pokemonData.round = -1;
        // TODO: run exit logic
        return (changedEntity, entityData);
      }
    } else {
      console.log("nothing to do");
    }

    return (changedEntity, entityData);
  }

  function calculateDamage(
    MoveData memory myMoveData,
    MoveData memory opponentMoveData
  ) internal pure returns (uint256) {
    uint256 damage = myMoveData.damage;
    // TODO: Figure out how to calculate random factor
    uint256 randomFactor = 1;
    uint256 typeMultiplier = getTypeMultiplier(myMoveData.moveType, opponentMoveData.moveType) / 100;
    return damage * typeMultiplier * randomFactor;
  }

  function calculateProtection(
    MoveData memory myMoveData,
    MoveData memory opponentMoveData
  ) internal pure returns (uint256) {
    uint256 protection = myMoveData.protection;
    // TODO: Figure out how to calculate random factor
    uint256 randomFactor = 1;
    uint256 typeMultiplier = getTypeMultiplier(myMoveData.moveType, opponentMoveData.moveType) / 100;
    return protection * typeMultiplier * randomFactor;
  }

  function getTypeMultiplier(PokemonType moveType, PokemonType neighbourPokemonType) internal pure returns (uint256) {
    if (moveType == PokemonType.Fire) {
      if (neighbourPokemonType == PokemonType.Fire) return 100;
      if (neighbourPokemonType == PokemonType.Water) return 50;
      if (neighbourPokemonType == PokemonType.Grass) return 200;
    } else if (moveType == PokemonType.Water) {
      if (neighbourPokemonType == PokemonType.Fire) return 200;
      if (neighbourPokemonType == PokemonType.Water) return 100;
      if (neighbourPokemonType == PokemonType.Grass) return 50;
    } else if (moveType == PokemonType.Grass) {
      if (neighbourPokemonType == PokemonType.Fire) return 50;
      if (neighbourPokemonType == PokemonType.Water) return 200;
      if (neighbourPokemonType == PokemonType.Grass) return 100;
    }
    revert("Invalid move types"); // Revert if none of the valid move types are matched
  }
}
