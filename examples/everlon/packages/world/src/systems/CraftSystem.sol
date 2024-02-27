// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { CraftSystem as CraftProtoSystem } from "@tenet-base-world/src/systems/CraftSystem.sol";

contract CraftSystem is CraftProtoSystem {
  function craft(bytes32 actingObjectEntityId, bytes32 recipeId, bytes32[] memory ingredientIds) public override {
    super.craft(actingObjectEntityId, recipeId, ingredientIds);
  }
}
