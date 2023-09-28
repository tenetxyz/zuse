// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { MindType } from "@tenet-base-ca/src/prototypes/MindType.sol";
import { Mind, VoxelCoord, VoxelEntity, InteractionSelector, CreationMetadata, CreationSpawns } from "@tenet-utils/src/Types.sol";
import { registerMindIntoRegistry } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, PokemonVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { getInteractionSelectors } from "@tenet-registry/src/Utils.sol";
import { isStringEqual } from "@tenet-utils/src/StringUtils.sol";
import { Pokemon, PokemonData, PokemonMove } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { entityIsEnergySource, entityIsSoil, entityIsPlant, entityIsPokemon } from "@tenet-pokemon-extension/src/InteractionUtils.sol";

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
      PokemonVoxelID,
      Mind({
        creationMetadata: abi.encode(creationMetadata),
        mindSelector: IWorld(_world()).pokemon_PokemonMindSyste_mindLogic.selector
      })
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

  function mindLogic(
    bytes32 voxelTypeId,
    bytes32 entity,
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
        // TODO: Should require that there is only ONE pokemon neighbour
        opponentPokemonEntityId = neighbourEntityIds[i];
        break;
      }
    }

    if (opponentPokemonEntityId != 0) {
      chosenSelector = getSelector(interactionSelectors, "Ember");
    } else {
      chosenSelector = getSelector(interactionSelectors, "Replenish Energy");
    }

    return chosenSelector;
  }
}
