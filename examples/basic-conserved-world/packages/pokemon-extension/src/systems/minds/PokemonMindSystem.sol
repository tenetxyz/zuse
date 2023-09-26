// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { MindType } from "@tenet-base-ca/src/prototypes/MindType.sol";
import { Mind, VoxelCoord, VoxelEntity, InteractionSelector, CreationMetadata, CreationSpawns } from "@tenet-utils/src/Types.sol";
import { registerMindIntoRegistry } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, PokemonVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { getInteractionSelectors } from "@tenet-registry/src/Utils.sol";

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
        creationMetadata: creationMetadata,
        mindSelector: IWorld(_world()).pokemon_PokemonMindSyste_mindLogic.selector
      })
    );
  }

  function mindLogic(
    bytes32 voxelTypeId,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes4) {
    InteractionSelector[] memory interactionSelectors = getInteractionSelectors(IStore(REGISTRY_ADDRESS), voxelTypeId);
    bytes4 chosenSelector = 0;
    for (uint i = 0; i < interactionSelectors.length; i++) {
      if (interactionSelectors[i].interactionName == "Replenish Energy") {
        chosenSelector = interactionSelectors[i].selector;
        break;
      }
    }
    return chosenSelector;
  }
}
