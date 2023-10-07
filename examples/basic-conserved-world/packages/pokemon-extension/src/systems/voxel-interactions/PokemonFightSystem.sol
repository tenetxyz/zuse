// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { calculateBlockDirection, safeSubtract } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { BlockDirection, VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { BlockDirection, BodySimData, VoxelCoord, CAEventData, CAEventType, SimEventData, SimTable, ObjectType } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { CAEntityReverseMapping, CAEntityReverseMappingTableId, CAEntityReverseMappingData } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";
import { Soil } from "@tenet-pokemon-extension/src/codegen/tables/Soil.sol";
import { Plant } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { PlantStage } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { Pokemon, PokemonData, PokemonMove } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { entityIsSoil, entityIsPlant, entityIsPokemon } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { getEntitySimData, transferEnergy } from "@tenet-level1-ca/src/Utils.sol";
import { isZeroCoord, voxelCoordsAreEqual } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { MoveData } from "@tenet-pokemon-extension/src/Types.sol";
import { console } from "forge-std/console.sol";

contract PokemonFightSystem is System {
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

  function getMoveData(PokemonMove move) public pure returns (MoveData memory) {
    MoveData[] memory movesData = getMovesData();
    return movesData[uint(move)];
  }

  function battleEndData(
    bytes32 entityId,
    uint256 lostHealth,
    uint256 lostStamina
  ) internal view returns (CAEventData[] memory) {
    if (lostHealth + lostStamina == 0) {
      return new CAEventData[](0);
    }
    BodySimData memory entitySimData = getEntitySimData(entityId);
    uint256 newEnergy = safeSubtract(entitySimData.energy, lostHealth + lostStamina);
    CAEntityReverseMappingData memory entityData = CAEntityReverseMapping.get(entityId);
    VoxelEntity memory entity = VoxelEntity({ scale: 1, entityId: entityData.entity });
    VoxelCoord memory coord = getCAEntityPositionStrict(IStore(_world()), entityId);
    CAEventData[] memory allCAEventData = new CAEventData[](1);
    SimEventData memory energyEventData = SimEventData({
      senderTable: SimTable.Energy,
      senderValue: abi.encode(entitySimData.energy),
      targetEntity: entity,
      targetCoord: coord,
      targetTable: SimTable.Energy,
      targetValue: abi.encode(newEnergy)
    });
    allCAEventData[0] = CAEventData({ eventType: CAEventType.SimEvent, eventData: abi.encode(energyEventData) });
    return allCAEventData;
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
    BodySimData memory entitySimData = getEntitySimData(interactEntity);
    BodySimData memory neighbourEntitySimData = getEntitySimData(neighbourEntity);

    // PokemonData memory neighbourPokemonData = Pokemon.get(callerAddress, neighbourEntity);
    // if (neighbourPokemonData.round == -1) {
    //   // This means battle is over, the neighbour pokemon is dead
    //   pokemonData.round = 0;
    //   pokemonData.move = PokemonMove.None;
    //   pokemonData.health = safeSubtract(pokemonData.health, pokemonData.lostHealth);
    //   pokemonData.stamina = safeSubtract(pokemonData.stamina, pokemonData.lostStamina);
    //   entityData = abi.encode(battleEndData(interactEntity, pokemonData.lostHealth, pokemonData.lostStamina));
    //   pokemonData.lostHealth = 0;
    //   pokemonData.lostStamina = 0;
    //   pokemonData.lastUpdatedBlock = block.number;

    //   return (changedEntity, entityData, pokemonData);
    // }

    if (
      entitySimData.actionData.actionType == ObjectType.None &&
      neighbourEntitySimData.actionData.actionType != ObjectType.None
    ) {
      // TODO: check actionEntity matches? We need this if we want multiple pokemon to be able to fight at the same time
      changedEntity = true;
      return (changedEntity, entityData, pokemonData);
    }

    // if (pokemonData.lostHealth >= pokemonData.health || pokemonData.lostStamina >= pokemonData.stamina) {
    //   // pokemon is fainted
    //   pokemonData.round = -1;
    //   pokemonData.move = PokemonMove.None;
    //   pokemonData.health = safeSubtract(pokemonData.health, pokemonData.lostHealth);
    //   pokemonData.stamina = safeSubtract(pokemonData.stamina, pokemonData.lostStamina);
    //   entityData = abi.encode(battleEndData(interactEntity, pokemonData.lostHealth, pokemonData.lostStamina));
    //   pokemonData.lostHealth = 0;
    //   pokemonData.lostStamina = 0;
    //   pokemonData.lastUpdatedBlock = block.number;

    //   if (neighbourPokemonData.round != -1) {
    //     changedEntity = true;
    //   }

    //   return (changedEntity, entityData, pokemonData);
    // }

    // if (
    //   entitySimData.actionData.actionType != ObjectType.None &&
    //   neighbourEntitySimData.actionData.actionType != ObjectType.None
    // ) {
    //   if (entitySimData.actionData.round != neighbourEntitySimData.actionData.round) {
    //     changedEntity = true;
    //     return (changedEntity, entityData, pokemonData);
    //   }

    // Calculate damage
    // MoveData[] memory movesData = getMovesData();
    // MoveData memory myMoveData = movesData[uint(pokemonData.move)];
    // MoveData memory opponentMoveData = movesData[uint(neighbourPokemonData.move)];
    // if (opponentMoveData.damage > 0 && myMoveData.protection > 0) {
    //   uint256 damage = calculateDamage(
    //     pokemonData.pokemonType,
    //     myMoveData,
    //     neighbourPokemonData.pokemonType,
    //     opponentMoveData
    //   );
    //   uint256 protection = calculateProtection(
    //     pokemonData.pokemonType,
    //     myMoveData,
    //     neighbourPokemonData.pokemonType,
    //     opponentMoveData
    //   );
    //   pokemonData.lostHealth += (damage - protection);
    // } else if (opponentMoveData.damage > 0) {
    //   uint256 damage = calculateDamage(
    //     pokemonData.pokemonType,
    //     myMoveData,
    //     neighbourPokemonData.pokemonType,
    //     opponentMoveData
    //   );
    //   pokemonData.lostHealth += damage;
    // }

    // changedEntity = true;
    // }

    return (changedEntity, entityData, pokemonData);
  }

  function calculateDamage(
    ObjectType myPokemonType,
    MoveData memory myMoveData,
    ObjectType opponentPokemonType,
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
    ObjectType myPokemonType,
    MoveData memory myMoveData,
    ObjectType opponentPokemonType,
    MoveData memory opponentMoveData
  ) internal pure returns (uint256) {
    uint256 protection = myMoveData.protection;
    // TODO: Figure out how to calculate random factor
    uint256 randomFactor = 1;
    uint256 moveTypeMultiplier = getTypeMultiplier(myPokemonType, opponentMoveData.moveType) / 100;
    uint256 myPokemonTypeMultiplier = getTypeMultiplier(myPokemonType, opponentPokemonType) / 100;
    return protection * myPokemonTypeMultiplier * moveTypeMultiplier * randomFactor;
  }

  function getTypeMultiplier(ObjectType moveType, ObjectType neighbourPokemonType) internal pure returns (uint256) {
    if (moveType == ObjectType.Fire) {
      if (neighbourPokemonType == ObjectType.Fire) return 100;
      if (neighbourPokemonType == ObjectType.Water) return 50;
      if (neighbourPokemonType == ObjectType.Grass) return 200;
    } else if (moveType == ObjectType.Water) {
      if (neighbourPokemonType == ObjectType.Fire) return 200;
      if (neighbourPokemonType == ObjectType.Water) return 100;
      if (neighbourPokemonType == ObjectType.Grass) return 50;
    } else if (moveType == ObjectType.Grass) {
      if (neighbourPokemonType == ObjectType.Fire) return 50;
      if (neighbourPokemonType == ObjectType.Water) return 200;
      if (neighbourPokemonType == ObjectType.Grass) return 100;
    }
    revert("Invalid move types"); // Revert if none of the valid move types are matched
  }
}
