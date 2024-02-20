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
import { GRANITE_SHINGLES_MASS, GraniteShinglesObjectID, GranitePolishedObjectID, GRANITE_POLISHED_MASS, GRANITE_CARVED_MASS, GraniteCarvedObjectID, GRANITE_BRICK_MASS, GraniteBrickObjectID, GraniteObjectID, SakuraLumberObjectID, RubberLumberObjectID, GoldPickObjectID, GOLD_PICK_MASS, GoldAxeObjectID, GOLD_AXE_MASS, GOLD_CUBE_MASS, GoldCubeObjectID, GOLD_BAR_MASS, GoldBarObjectID, GoldOreObjectID, GlassObjectID, GLASS_MASS, SandObjectID, EMBERSTONE_MASS, EmberstoneObjectID, StoneObjectID, CoalOreObjectID, DIAMOND_PICK_MASS, DiamondPickObjectID, DIAMOND_CUBE_MASS, DiamondCubeObjectID, DIAMOND_AXE_MASS, DiamondAxeObjectID, DIAMOND_MASS, DiamondObjectID, DiamondOreObjectID, COTTON_BLOCK_MASS, CottonBlockObjectID, CottonObjectID, COBBLESTONE_BRICK_MASS, CobblestoneBrickObjectID, CobblestoneObjectID, ChestObjectID, CHEST_MASS, ClayShinglesObjectID, CLAY_SHINGLES_MASS, CLAY_POLISHED_MASS, ClayPolishedObjectID, CLAY_CARVED_MASS, ClayCarvedObjectID, CLAY_BRICK_MASS, ClayBrickObjectID, DirtObjectID, ClayObjectID, CLAY_MASS, MuckshroomObjectID, BellflowerObjectID, BlueMushroomSporeObjectID, BLUE_MUSHROOM_SPORE_MASS, BirchLogObjectID, ReinforcedBirchLumberObjectID, REINFORCED_BIRCH_LUMBER_MASS, BirchLumberObjectID, SilverOreObjectID, BIRCH_LUMBER_MASS, OakLogObjectID, OakLumberObjectID, OAK_LUMBER_MASS, BASALT_BRICK_MASS, BASALT_CARVED_MASS, BASALT_POLISHED_MASS, BASALT_SHINGLES_MASS, WoodenPickObjectID, WOODEN_PICK_MASS, BasaltObjectID, PaperObjectID, BasaltBrickObjectID, BasaltCarvedObjectID, BasaltPolishedObjectID, BasaltShinglesObjectID, PAPER_MASS } from "@tenet-world/src/Constants.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";


contract RecipeSystemTwo is System {
  function initRecipesTwo() public {

    // recipeGraniteBrick

    bytes32[] memory inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = GraniteObjectID; // Defined earlier
    inputObjectTypeIds[1] = PaperObjectID; // Defined earlier
    uint8[] memory inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Granite
    inputObjectTypeAmounts[1] = 1; // 1 Paper

    bytes32[] memory outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = GraniteBrickObjectID; // TODO: Define GraniteBrickObjectID
    uint8[] memory outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Granite Brick

    ObjectProperties[] memory outputObjectProperties = new ObjectProperties[](1);
    ObjectProperties memory outputOutputProperties;
    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = GRANITE_BRICK_MASS; // TODO: Define GRANITE_BRICK_MASS
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

    // recipeGraniteCarved

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = GraniteBrickObjectID; // Defined in the previous recipe
    inputObjectTypeIds[1] = PaperObjectID; // Defined earlier
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Granite Brick
    inputObjectTypeAmounts[1] = 1; // 1 Paper

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = GraniteCarvedObjectID; // TODO: Define GraniteCarvedObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Granite Carved

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = GRANITE_CARVED_MASS; // TODO: Define GRANITE_CARVED_MASS
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

    // recipeGranitePolished

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = GraniteBrickObjectID; // From Granite Brick recipe
    inputObjectTypeIds[1] = PaperObjectID; // Defined earlier
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Granite Brick
    inputObjectTypeAmounts[1] = 1; // 1 Paper

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = GranitePolishedObjectID;
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Granite Polished

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = GRANITE_POLISHED_MASS;
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


    // recipeGraniteShingles

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = GraniteBrickObjectID; // From Granite Brick recipe
    inputObjectTypeIds[1] = PaperObjectID; // Defined earlier
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Granite Brick
    inputObjectTypeAmounts[1] = 1; // 1 Paper

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = GraniteShinglesObjectID; // TODO: Define GraniteShinglesObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Granite Shingles

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = GRANITE_SHINGLES_MASS; // TODO: Define GRANITE_SHINGLES_MASS
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

    // recipeGoldPick

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = GoldBarObjectID; // TODO: Define GoldBarObjectID
    inputObjectTypeIds[1] = OakLogObjectID; // Assuming OakLogObjectID for "log", adjust if necessary
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Gold Bar
    inputObjectTypeAmounts[1] = 4; // 4 Log

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = GoldPickObjectID; // TODO: Define GoldPickObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Pick

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = GOLD_PICK_MASS; // TODO: Define GOLD_PICK_MASS
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


  }
}