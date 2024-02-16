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

import { initializeBytes32Array } from "@tenet-utils/src/ArrayUtils.sol";
import { OakLogObjectID, OakLumberObjectID, OAK_LUMBER_MASS } from "@tenet-world/src/Constants.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

contract RecipeSystem is System {
  // TODO: Make this only callable once
  function initRecipes() public {
    // Oak Log -> Oak Lumber

    // Recipe inputs
    bytes32[] memory inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = OakLogObjectID;
    uint32[] memory inputObjectTypeAmounts = new uint32[](1);
    inputObjectTypeAmounts[0] = 1;

    // Recipe outputs
    bytes32[] memory outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = OakLumberObjectID;
    uint32[] memory outputObjectTypeAmounts = new uint32[](1);
    outputObjectTypeAmounts[0] = 1;
    ObjectProperties[] memory outputObjectProperties = new ObjectProperties[](1);
    ObjectProperties memory lumberOutputProperties;
    lumberOutputProperties.mass = OAK_LUMBER_MASS;
    outputObjectProperties[0] = lumberOutputProperties;

    bytes32 newRecipeId = getUniqueEntity();
    Recipes.set(
      newRecipeId,
      RecipesData({
        inputObjectTypeIds: inputObjectTypeIds,
        inputObjectTypeAmounts: inputObjectTypeAmounts,
        outputObjectTypeIds: outputObjectTypeIds,
        outputObjectTypeAmounts: outputObjectTypeAmounts,
        outputObjectProperties: abi.encode(outputObjectProperties)
      })
    );
  }
}
