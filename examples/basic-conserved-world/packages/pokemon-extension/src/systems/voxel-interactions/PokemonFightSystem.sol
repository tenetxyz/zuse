// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { calculateBlockDirection, safeSubtract } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { BlockDirection, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { BlockDirection, BodyPhysicsData, VoxelCoord, CAEventData } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { Soil } from "@tenet-pokemon-extension/src/codegen/tables/Soil.sol";
import { Plant } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { PlantStage } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { Pokemon, PokemonData, PokemonMove, PokemonType } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { entityIsSoil, entityIsPlant, entityIsPokemon } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
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
  function getMovesData() internal pure returns (MoveData[] memory) {
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

  function getStaminaCost(PokemonMove move) public pure returns (uint8) {
    MoveData[] memory movesData = getMovesData();
    return movesData[uint(move)].stamina;
  }

  function battleEndData(uint256 lostHealth, uint256 lostStamina) internal pure returns (CAEventData memory) {
    uint256[] memory energyFluxAmounts = new uint256[](1);
    energyFluxAmounts[0] = lostHealth + lostStamina;
    // return
    //   CAEventData({
    //     eventType: CAEventType.FluxEnergyAndMass,
    //     newCoords: new VoxelCoord[](0),
    //     energyFluxAmounts: energyFluxAmounts,
    //     massFluxAmount: 0
    //   });
  }

  function runBattleLogic(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntity,
    PokemonData memory pokemonData
  ) public view returns (bool changedEntity, bytes memory entityData, PokemonData memory) {
    if (!entityIsPokemon(callerAddress, neighbourEntity)) {
      return (changedEntity, entityData, pokemonData);
    }

    PokemonData memory neighbourPokemonData = Pokemon.get(callerAddress, neighbourEntity);
    if (neighbourPokemonData.round == -1) {
      // This means battle is over, the neighbour pokemon is dead
      pokemonData.round = 0;
      pokemonData.move = PokemonMove.None;
      pokemonData.health = safeSubtract(pokemonData.health, pokemonData.lostHealth);
      pokemonData.stamina = safeSubtract(pokemonData.stamina, pokemonData.lostStamina);
      entityData = abi.encode(battleEndData(pokemonData.lostHealth, pokemonData.lostStamina));
      pokemonData.lostHealth = 0;
      pokemonData.lostStamina = 0;
      pokemonData.lastUpdatedBlock = block.number;

      return (changedEntity, entityData, pokemonData);
    }

    if (pokemonData.move == PokemonMove.None && neighbourPokemonData.move != PokemonMove.None) {
      changedEntity = true;
      return (changedEntity, entityData, pokemonData);
    }

    if (pokemonData.lostHealth >= pokemonData.health || pokemonData.lostStamina >= pokemonData.stamina) {
      // pokemon is fainted
      pokemonData.round = -1;
      pokemonData.move = PokemonMove.None;
      pokemonData.health = safeSubtract(pokemonData.health, pokemonData.lostHealth);
      pokemonData.stamina = safeSubtract(pokemonData.stamina, pokemonData.lostStamina);
      entityData = abi.encode(battleEndData(pokemonData.lostHealth, pokemonData.lostStamina));
      pokemonData.lostHealth = 0;
      pokemonData.lostStamina = 0;
      pokemonData.lastUpdatedBlock = block.number;

      if (neighbourPokemonData.round != -1) {
        changedEntity = true;
      }

      return (changedEntity, entityData, pokemonData);
    }

    if (pokemonData.move != PokemonMove.None && neighbourPokemonData.move != PokemonMove.None) {
      if (pokemonData.round != neighbourPokemonData.round) {
        changedEntity = true;
        return (changedEntity, entityData, pokemonData);
      }

      // Calculate damage
      MoveData[] memory movesData = getMovesData();
      MoveData memory myMoveData = movesData[uint(pokemonData.move)];
      MoveData memory opponentMoveData = movesData[uint(neighbourPokemonData.move)];
      if (opponentMoveData.damage > 0 && myMoveData.protection > 0) {
        uint256 damage = calculateDamage(
          pokemonData.pokemonType,
          myMoveData,
          neighbourPokemonData.pokemonType,
          opponentMoveData
        );
        uint256 protection = calculateProtection(
          pokemonData.pokemonType,
          myMoveData,
          neighbourPokemonData.pokemonType,
          opponentMoveData
        );
        pokemonData.lostHealth += (damage - protection);
      } else if (opponentMoveData.damage > 0) {
        uint256 damage = calculateDamage(
          pokemonData.pokemonType,
          myMoveData,
          neighbourPokemonData.pokemonType,
          opponentMoveData
        );
        pokemonData.lostHealth += damage;
      }

      changedEntity = true;
    }

    return (changedEntity, entityData, pokemonData);
  }

  function calculateDamage(
    PokemonType myPokemonType,
    MoveData memory myMoveData,
    PokemonType opponentPokemonType,
    MoveData memory opponentMoveData
  ) internal pure returns (uint256) {
    uint256 damage = myMoveData.damage;
    // TODO: Figure out how to calculate random factor
    uint256 randomFactor = 1;
    uint256 moveTypeMultiplier = getTypeMultiplier(myPokemonType, opponentMoveData.moveType) / 100;
    uint256 myPokemonTypeMultiplier = getTypeMultiplier(myPokemonType, opponentPokemonType) / 100;
    return damage * myPokemonTypeMultiplier * moveTypeMultiplier * randomFactor;
  }

  function calculateProtection(
    PokemonType myPokemonType,
    MoveData memory myMoveData,
    PokemonType opponentPokemonType,
    MoveData memory opponentMoveData
  ) internal pure returns (uint256) {
    uint256 protection = myMoveData.protection;
    // TODO: Figure out how to calculate random factor
    uint256 randomFactor = 1;
    uint256 moveTypeMultiplier = getTypeMultiplier(myPokemonType, opponentMoveData.moveType) / 100;
    uint256 myPokemonTypeMultiplier = getTypeMultiplier(myPokemonType, opponentPokemonType) / 100;
    return protection * myPokemonTypeMultiplier * moveTypeMultiplier * randomFactor;
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
