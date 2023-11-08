// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { getEntitySimData } from "@tenet-level1-ca/src/Utils.sol";
import { BodySimData } from "@tenet-utils/src/Types.sol";
import { registerMindIntoRegistry, getSelector } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, GrassPokemonVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { MindType } from "@tenet-base-ca/src/prototypes/MindType.sol";
import { console } from "forge-std/console.sol";
import { InteractionSelector } from "@tenet-utils/src/Types.sol";
import { getInteractionSelectors } from "@tenet-registry/src/Utils.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";

contract GrassMindSystem is MindType {
  function registerMind() public {
    registerMindIntoRegistry(
      REGISTRY_ADDRESS,
      GrassPokemonVoxelID,
      "grass Mind",
      "grass desc",
      IWorld(_world()).pokemon_GrassMindSystem_mindLogic.selector
    );
  }

  function mindLogic(
    bytes32 voxelTypeId,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes4) {
    console.log("attacking 0x70d19e30 grass mind whip");
    InteractionSelector[] memory interactionSelectors = getInteractionSelectors(
      IStore(REGISTRY_ADDRESS),
      GrassPokemonVoxelID
    );
    return getSelector(interactionSelectors, "Vine Whip");
  }
}
