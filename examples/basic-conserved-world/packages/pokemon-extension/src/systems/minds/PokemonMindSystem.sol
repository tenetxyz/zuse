// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { MindType } from "@tenet-base-ca/src/prototypes/MindType.sol";
import { Mind, VoxelCoord, VoxelEntity, InteractionSelector, CreationMetadata, CreationSpawns } from "@tenet-utils/src/Types.sol";
import { registerMindIntoRegistry } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, FirePokemonVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { getInteractionSelectors } from "@tenet-registry/src/Utils.sol";
import { isStringEqual } from "@tenet-utils/src/StringUtils.sol";
import { Pokemon, PokemonData, PokemonMove } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { entityIsEnergySource, entityIsSoil, entityIsPlant, entityIsPokemon } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { console } from "forge-std/console.sol";
import { getVoxelBodyPhysicsFromCaller, transferEnergy } from "@tenet-level1-ca/src/Utils.sol";
import { BlockDirection, BodyPhysicsData, CAEventData, CAEventType, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { isZeroCoord, voxelCoordsAreEqual } from "@tenet-utils/src/VoxelCoordUtils.sol";

contract PokemonMindSystem is MindType {
  function registerMind() public {
    CreationMetadata memory creationMetadata = CreationMetadata({
      creator: tx.origin,
      name: "Pokemon Mind",
      description: "",
      spawns: new CreationSpawns[](0)
    });
    registerMindIntoRegistry(
      REGISTRY_ADDRESS,
      FirePokemonVoxelID,
      "Pokemon Mind",
      "Tells us how pokemons fight",
      IWorld(_world()).pokemon_PokemonMindSyste_mindLogic.selector
    );
  }

  function getSelector(
    InteractionSelector[] memory interactionSelectors,
    string memory selectorName
  ) public pure returns (bytes4) {
    for (uint i = 0; i < interactionSelectors.length; i++) {
      if (isStringEqual(interactionSelectors[i].interactionName, selectorName)) {
        return interactionSelectors[i].interactionSelector;
      }
    }
    revert("Selector not found");
  }

  function canFight(address callerAddress, bytes32 pokemonEntityId) public view returns (bool) {
    BodyPhysicsData memory entityBodyPhysics = getVoxelBodyPhysicsFromCaller(pokemonEntityId);
    VoxelCoord memory currentVelocity = abi.decode(entityBodyPhysics.velocity, (VoxelCoord));
    if (!isZeroCoord(currentVelocity)) {
      return false;
    }
    PokemonData memory pokemonData = Pokemon.get(callerAddress, pokemonEntityId);
    if (pokemonData.health == 0) {
      return false;
    }
    if (pokemonData.round == -1) {
      return false;
    }
    return true;
  }

  function mindLogic(
    bytes32 voxelTypeId,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes4) {
    address callerAddress = super.getCallerAddress();
    InteractionSelector[] memory interactionSelectors = getInteractionSelectors(IStore(REGISTRY_ADDRESS), voxelTypeId);
    bytes4 chosenSelector = 0;
    bytes32 opponentPokemonEntityId = 0;

    // Check if neighbour is pokemon
    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }

      if (entityIsPokemon(callerAddress, neighbourEntityIds[i])) {
        opponentPokemonEntityId = neighbourEntityIds[i];
        break;
      }
    }

    if (opponentPokemonEntityId != 0) {
      if (canFight(callerAddress, interactEntity) && canFight(callerAddress, opponentPokemonEntityId)) {
        chosenSelector = getSelector(interactionSelectors, "Ember");
      }
    } else {
      chosenSelector = getSelector(interactionSelectors, "Replenish Energy");
    }

    return chosenSelector;
  }
}
