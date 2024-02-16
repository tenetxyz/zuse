// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

import { Recipes, RecipesData, RecipesTableId } from "@tenet-world/src/codegen/tables/Recipes.sol";
import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";
import { Inventory, InventoryTableId } from "@tenet-base-world/src/codegen/tables/Inventory.sol";
import { InventoryObject } from "@tenet-base-world/src/codegen/tables/InventoryObject.sol";

import { initializeBytes32Array } from "@tenet-utils/src/ArrayUtils.sol";
import { OakLogObjectID, OakLumberObjectID, OAK_LUMBER_MASS } from "@tenet-world/src/Constants.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

contract RecipeSystem is System {
  function initRecipes() public {
    // Log to Planks
    bytes32[][] memory recipe = initializeBytes32Array(1, 1);
    recipe[0][0] = OakLogObjectID;

    ObjectProperties memory outputProperties;
    outputProperties.mass = OAK_LUMBER_MASS;
    Recipes.set(
      keccak256(abi.encode(recipe)),
      RecipesData({ objectTypeId: OakLumberObjectID, objectProperties: abi.encode(outputProperties) })
    );
  }
}
