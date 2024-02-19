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
import { OakLogObjectID, OakLumberObjectID, OAK_LUMBER_MASS, WoodenPickObjectID, WOODEN_PICK_MASS, BasaltObjectID, PaperObjectID, BasaltBrickObjectID, BasaltCarvedObjectID, BasaltPolishedObjectID, BasaltShinglesObjectID } from "@tenet-world/src/Constants.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

contract RecipeSystem is System {
  // TODO: Make this only callable once
  function initRecipes() public {
    // 1 oak log -> 4 oak lumber

    // Recipe inputs
    bytes32[] memory inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = OakLogObjectID;
    uint8[] memory inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 1;

    // Recipe outputs
    bytes32[] memory outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = OakLumberObjectID;
    uint8[] memory outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4;
    ObjectProperties[] memory outputObjectProperties = new ObjectProperties[](1);
    ObjectProperties memory outputOutputProperties;
    outputOutputProperties.mass = OAK_LUMBER_MASS;
    outputObjectProperties[0] = outputOutputProperties;

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


    // 4 oak log -> 1 wooden pick

    // Recipe inputs
    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = OakLogObjectID;
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 4;

    // Recipe outputs
    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = WoodenPickObjectID;
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1;
    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = WOODEN_PICK_MASS;
    outputObjectProperties[0] = outputOutputProperties;

    newRecipeId = getUniqueEntity();
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


    // recipeBasaltBrick
    
    // Recipe inputs
    bytes32[] memory inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = BasaltObjectID;
    inputObjectTypeIds[1] = PaperObjectID;
    uint8[] memory inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4;
    inputObjectTypeAmounts[1] = 4;

    // Recipe outputs
    bytes32[] memory outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = BasaltBrickObjectID;
    uint8[] memory outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4;

    ObjectProperties[] memory outputObjectProperties = new ObjectProperties[](1);
    ObjectProperties memory outputProperties;
    outputProperties.mass = BASALT_BRICK_MASS;
    outputObjectProperties[0] = outputProperties;

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
    

    // recipeBasaltCarved
    
    // Recipe inputs
    bytes32[] memory inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = BasaltBrickObjectID;
    inputObjectTypeIds[1] = PaperObjectID;
    uint8[] memory inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4;
    inputObjectTypeAmounts[1] = 4;

    // Recipe outputs
    bytes32[] memory outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = BasaltCarvedObjectID;
    uint8[] memory outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4;

    ObjectProperties[] memory outputObjectProperties = new ObjectProperties[](1);
    ObjectProperties memory outputProperties;
    outputProperties.mass = BASALT_CARVED_MASS;
    outputObjectProperties[0] = outputProperties;

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


    // recipeBasaltPolished
    
    // Identical structure to recipeBasaltCarved, with adjusted output type
    // Recipe inputs
    bytes32[] memory inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = BasaltBrickObjectID;
    inputObjectTypeIds[1] = PaperObjectID;
    uint8[] memory inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4;
    inputObjectTypeAmounts[1] = 4;

    // Recipe outputs
    bytes32[] memory outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = BasaltPolishedObjectID;
    uint8[] memory outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4;

    ObjectProperties[] memory outputObjectProperties = new ObjectProperties[](1);
    ObjectProperties memory outputProperties;
    outputProperties.mass = BASALT_POLISHED_MASS;
    outputObjectProperties[0] = outputProperties;

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
    

    // recipeBasaltShingles
    // Identical structure to recipeBasaltCarved, with adjusted output type
    // Recipe inputs
    bytes32[] memory inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = BasaltBrickObjectID;
    inputObjectTypeIds[1] = PaperObjectID;
    uint8[] memory inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4;
    inputObjectTypeAmounts[1] = 4;

    // Recipe outputs
    bytes32[] memory outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = BasaltShinglesObjectID;
    uint8[] memory outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4;

    ObjectProperties[] memory outputObjectProperties = new ObjectProperties[](1);
    ObjectProperties memory outputProperties;
    outputProperties.mass = BASALT_SHINGLES_MASS;
    outputObjectProperties[0] = outputProperties;

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
