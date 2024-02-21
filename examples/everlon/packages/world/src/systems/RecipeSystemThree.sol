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
import { WoodenWhackerObjectID, WOODEN_WHACKER_MASS, WoodenAxeObjectID, WOODEN_AXE_MASS, SunstoneObjectID, SUNSTONE_MASS, SilverWhackerObjectID, SILVER_WHACKER_MASS, SilverPickObjectID, SILVER_PICK_MASS, SilverAxeObjectID, SILVER_AXE_MASS, SilverCubeObjectID, SILVER_CUBE_MASS, SILVER_BAR_MASS, SilverBarObjectID, SakuraLogObjectID, SakuraLumberObjectID, SAKURA_LUMBER_MASS, RubbleObjectID, RUBBLE_MASS, ReinforcedRubberLumberObjectID, REINFORCED_RUBBER_LUMBER_MASS, RubberLogObjectID, RUBBER_LUMBER_MASS, RedMushroomSporesObjectID, RED_MUSHROOM_SPORES_MASS, QuartziteShinglesObjectID, QUARTZITE_SHINGLES_MASS, QuartzitePolishedObjectID, QUARTZITE_POLISHED_MASS, QuartziteCarvedObjectID, QUARTZITE_CARVED_MASS, QuartziteBrickObjectID, QUARTZITE_BRICK_MASS, MuckshroomSporesObjectID, MUCKSHROOM_SPORES_MASS, ReinforcedOakLumberObjectID, REINFORCED_OAK_LUMBER_MASS, NeptuniumPickObjectID, MOONSTONE_MASS, NeptuniumAxeObjectID, NEPTUNIUM_AXE_MASS, NEPTUNIUM_PICK_MASS, NeptuniumCubeObjectID, NEPTUNIUM_CUBE_MASS, NeptuniumOreObjectID, NEPTUNIUM_BAR_MASS, NeptuniumBarObjectID, RedMushroomObjectID, MushroomLeatherBlockObjectID, MUSHROOM_LEATHER_BLOCK_MASS, MoonstoneObjectID, QuartziteObjectID, LIMESTONE_CARVED_MASS, LIMESTONE_SHINGLES_MASS, LIMESTONE_POLISHED_MASS, LimestoneShinglesObjectID, LimestonePolishedObjectID, LimestoneCarvedObjectID, LimestoneObjectID, LimestoneBrickObjectID, LIMESTONE_BRICK_MASS, GRANITE_SHINGLES_MASS, GraniteShinglesObjectID, GranitePolishedObjectID, GRANITE_POLISHED_MASS, GRANITE_CARVED_MASS, GraniteCarvedObjectID, GRANITE_BRICK_MASS, GraniteBrickObjectID, GraniteObjectID, SakuraLumberObjectID, RubberLumberObjectID, GoldPickObjectID, GOLD_PICK_MASS, GoldAxeObjectID, GOLD_AXE_MASS, GOLD_CUBE_MASS, GoldCubeObjectID, GOLD_BAR_MASS, GoldBarObjectID, GoldOreObjectID, GlassObjectID, GLASS_MASS, SandObjectID, EMBERSTONE_MASS, EmberstoneObjectID, StoneObjectID, CoalOreObjectID, DIAMOND_PICK_MASS, DiamondPickObjectID, DIAMOND_CUBE_MASS, DiamondCubeObjectID, DIAMOND_AXE_MASS, DiamondAxeObjectID, DIAMOND_MASS, DiamondObjectID, DiamondOreObjectID, COTTON_BLOCK_MASS, CottonBlockObjectID, CottonObjectID, COBBLESTONE_BRICK_MASS, CobblestoneBrickObjectID, CobblestoneObjectID, ChestObjectID, CHEST_MASS, ClayShinglesObjectID, CLAY_SHINGLES_MASS, CLAY_POLISHED_MASS, ClayPolishedObjectID, CLAY_CARVED_MASS, ClayCarvedObjectID, CLAY_BRICK_MASS, ClayBrickObjectID, DirtObjectID, ClayObjectID, CLAY_MASS, MuckshroomObjectID, BellflowerObjectID, BlueMushroomSporeObjectID, BLUE_MUSHROOM_SPORE_MASS, BirchLogObjectID, ReinforcedBirchLumberObjectID, REINFORCED_BIRCH_LUMBER_MASS, BirchLumberObjectID, SilverOreObjectID, BIRCH_LUMBER_MASS, OakLogObjectID, OakLumberObjectID, OAK_LUMBER_MASS, BASALT_BRICK_MASS, BASALT_CARVED_MASS, BASALT_POLISHED_MASS, BASALT_SHINGLES_MASS, WoodenPickObjectID, WOODEN_PICK_MASS, BasaltObjectID, PaperObjectID, BasaltBrickObjectID, BasaltCarvedObjectID, BasaltPolishedObjectID, BasaltShinglesObjectID, PAPER_MASS } from "@tenet-world/src/Constants.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";


contract RecipeSystemThree is System {
  function initRecipesThree() public {

    // recipeSilverBar

    bytes32[] memory inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = SilverOreObjectID; // Assuming SilverOreObjectID represents "silver nugget"
    uint8[] memory inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 4; // 4 Silver Nugget

    bytes32[] memory outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = SilverBarObjectID; // TODO: Define SilverBarObjectID
    uint8[] memory outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Silver Bar

    ObjectProperties[] memory outputObjectProperties = new ObjectProperties[](1);
    ObjectProperties memory outputOutputProperties;
    outputOutputProperties.mass = SILVER_BAR_MASS; // TODO: Define SILVER_BAR_MASS
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

    // recipeSilverAxe

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = SilverBarObjectID; // From Silver Bar recipe
    inputObjectTypeIds[1] = OakLogObjectID; // Assuming OakLogObjectID for "log", adjust if necessary
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Silver Bar
    inputObjectTypeAmounts[1] = 4; // 4 Log

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = SilverAxeObjectID; // TODO: Define SilverAxeObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Silver Axe

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = SILVER_AXE_MASS; // TODO: Define SILVER_AXE_MASS
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

    // recipeSilverCube

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = SilverBarObjectID; // From Silver Bar recipe
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 8; // 8 Silver Bar

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = SilverCubeObjectID; // TODO: Define SilverCubeObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Silver Cube

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = SILVER_CUBE_MASS; // TODO: Define SILVER_CUBE_MASS
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

    // recipeSilverPick

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = SilverBarObjectID; // From Silver Bar recipe
    inputObjectTypeIds[1] = OakLogObjectID; // Assuming OakLogObjectID for "log", adjust if necessary
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Silver Bar
    inputObjectTypeAmounts[1] = 4; // 4 Log

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = SilverPickObjectID; // TODO: Define SilverPickObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Silver Pick

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = SILVER_PICK_MASS; // TODO: Define SILVER_PICK_MASS
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

    // recipeSilverWhacker

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = SilverBarObjectID; // From Silver Bar recipe
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 6; // 6 Silver Bar

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = SilverWhackerObjectID; // TODO: Define SilverWhackerObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Silver Whacker

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = SILVER_WHACKER_MASS; // TODO: Define SILVER_WHACKER_MASS
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

    // recipeSunstone

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = CoalOreObjectID; // Assuming CoalOreObjectID for "coal nuggets"
    inputObjectTypeIds[1] = LimestoneObjectID; // Assuming LimestoneObjectID is correct
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Coal Nuggets
    inputObjectTypeAmounts[1] = 4; // 4 Limestone

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = SunstoneObjectID; // Assuming SunstoneObjectID needs to be defined
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Sunstone

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = SUNSTONE_MASS; // Assuming SUNSTONE_MASS needs to be defined
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

    // recipeWoodenAxe

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = OakLogObjectID; // Using OakLogObjectID as a placeholder for "log"
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 4; // 4 Log

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = WoodenAxeObjectID; // Assuming WoodenAxeObjectID needs to be defined
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Wooden Axe

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = WOODEN_AXE_MASS; // Assuming WOODEN_AXE_MASS needs to be defined
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

    // recipeWoodenWhacker

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = OakLogObjectID; // Using OakLogObjectID as a placeholder for "log"
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 8; // 8 Log

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = WoodenWhackerObjectID; // Assuming WoodenWhackerObjectID needs to be defined
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Wooden Whacker

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = WOODEN_WHACKER_MASS; // Assuming WOODEN_WHACKER_MASS needs to be defined
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