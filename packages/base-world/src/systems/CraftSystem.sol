// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/haskeys/hasKey.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";

import { Recipes, RecipesData, RecipesTableId } from "@tenet-base-world/src/codegen/tables/Recipes.sol";
import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";
import { Inventory, InventoryTableId } from "@tenet-base-world/src/codegen/tables/Inventory.sol";
import { InventoryObject } from "@tenet-base-world/src/codegen/tables/InventoryObject.sol";

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

abstract contract CraftSystem is System {
  function craft(bytes32 actingObjectEntityId, bytes32 recipeId, bytes32[] memory ingredientIds) public virtual {
    require(hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(actingObjectEntityId)), "CraftSystem: entity has no owner");
    require(OwnedBy.get(actingObjectEntityId) == _msgSender(), "CraftSystem: caller does not own entity");

    RecipesData memory recipeData = Recipes.get(recipeId);
    require(recipeData.inputObjectTypeIds.length > 0, "CraftSystem: recipe not found");

    // Require that the acting object has all the ingredients in its inventory
    // And delete the ingredients from the inventory as they are used
    for (uint256 i = 0; i < recipeData.inputObjectTypeIds.length; i++) {
      for (uint256 j = 0; j < ingredientIds.length; j++) {
        if (Inventory.get(ingredientIds[j]) == actingObjectEntityId) {
          bytes32 ingredientObjectTypeId = InventoryObject.getObjectTypeId(ingredientIds[j]);
          if (ingredientObjectTypeId == recipeData.inputObjectTypeIds[i]) {
            uint8 numObjects = InventoryObject.getNumObjects(ingredientIds[j]);
            require(numObjects >= recipeData.inputObjectTypeAmounts[i], "CraftSystem: not enough ingredients");

            IWorld(_world()).removeObjectFromInventory(ingredientIds[j], recipeData.inputObjectTypeAmounts[i]);
          }
        }
      }
    }

    // Create the crafted objects
    ObjectProperties[] memory outputObjectProperties = abi.decode(
      recipeData.outputObjectProperties,
      (ObjectProperties[])
    );
    for (uint256 i = 0; i < recipeData.outputObjectTypeIds.length; i++) {
      IWorld(_world()).addObjectToInventory(
        actingObjectEntityId,
        recipeData.outputObjectTypeIds[i],
        recipeData.outputObjectTypeAmounts[i],
        outputObjectProperties[i]
      );
    }
  }
}
