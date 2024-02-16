// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";

import { Recipes, RecipesData, RecipesTableId } from "@tenet-world/src/codegen/tables/Recipes.sol";
import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";
import { Inventory, InventoryTableId } from "@tenet-base-world/src/codegen/tables/Inventory.sol";
import { InventoryObject } from "@tenet-base-world/src/codegen/tables/InventoryObject.sol";

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

contract CraftSystem is System {
  function craft(bytes32 actingObjectEntityId, bytes32[][] memory ingredientIds) public returns (bytes32) {
    require(hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(actingObjectEntityId)), "CraftSystem: entity has no owner");
    require(OwnedBy.get(actingObjectEntityId) == _msgSender(), "CraftSystem: caller does not own entity");

    // Require that the acting object has all the ingredients in its inventory
    bytes32[][] memory ingredientObjectTypeIds = new bytes32[][](ingredientIds.length);
    for (uint256 i = 0; i < ingredientIds.length; i++) {
      ingredientObjectTypeIds[i] = new bytes32[](ingredientIds[i].length);
    }
    for (uint256 i = 0; i < ingredientIds.length; i++) {
      for (uint256 j = 0; j < ingredientIds[i].length; j++) {
        if (ingredientIds[i][j] == bytes32(0)) {
          continue;
        }
        require(Inventory.get(ingredientIds[i][j]) == actingObjectEntityId, "CraftSystem: ingredient not in inventory");
        ingredientObjectTypeIds[i][j] = InventoryObject.getObjectTypeId(ingredientIds[i][j]);
      }
    }

    // Get recipe for the ingredients
    bytes32 ingredientObjectTypeIdsHash = keccak256(abi.encode(ingredientObjectTypeIds));
    RecipesData memory recipeData = Recipes.get(ingredientObjectTypeIdsHash);
    require(recipeData.objectTypeId != bytes32(0), "CraftSystem: no recipe found for ingredients");

    // Delete the ingredients from the inventory
    for (uint256 i = 0; i < ingredientIds.length; i++) {
      for (uint256 j = 0; j < ingredientIds[i].length; j++) {
        if (ingredientIds[i][j] == bytes32(0)) {
          continue;
        }
        Inventory.deleteRecord(ingredientIds[i][j]);
        InventoryObject.deleteRecord(ingredientIds[i][j]);
      }
    }

    // Create the crafted object
    bytes32 inventoryId = getUniqueEntity();
    Inventory.set(inventoryId, actingObjectEntityId);
    InventoryObject.set(inventoryId, recipeData.objectTypeId, recipeData.objectProperties);

    return inventoryId;
  }
}
