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
import { NeptuniumPickObjectID, MOONSTONE_MASS, NeptuniumAxeObjectID, NEPTUNIUM_AXE_MASS, NEPTUNIUM_PICK_MASS, NeptuniumCubeObjectID, NEPTUNIUM_CUBE_MASS, NeptuniumOreObjectID, NEPTUNIUM_BAR_MASS, NeptuniumBarObjectID, RedMushroomObjectID, MushroomLeatherBlockObjectID, MUSHROOM_LEATHER_BLOCK_MASS, MoonstoneObjectID, QuartziteObjectID, LIMESTONE_CARVED_MASS, LIMESTONE_SHINGLES_MASS, LIMESTONE_POLISHED_MASS, LimestoneShinglesObjectID, LimestonePolishedObjectID, LimestoneCarvedObjectID, LimestoneObjectID, LimestoneBrickObjectID, LIMESTONE_BRICK_MASS, GRANITE_SHINGLES_MASS, GraniteShinglesObjectID, GranitePolishedObjectID, GRANITE_POLISHED_MASS, GRANITE_CARVED_MASS, GraniteCarvedObjectID, GRANITE_BRICK_MASS, GraniteBrickObjectID, GraniteObjectID, SakuraLumberObjectID, RubberLumberObjectID, GoldPickObjectID, GOLD_PICK_MASS, GoldAxeObjectID, GOLD_AXE_MASS, GOLD_CUBE_MASS, GoldCubeObjectID, GOLD_BAR_MASS, GoldBarObjectID, GoldOreObjectID, GlassObjectID, GLASS_MASS, SandObjectID, EMBERSTONE_MASS, EmberstoneObjectID, StoneObjectID, CoalOreObjectID, DIAMOND_PICK_MASS, DiamondPickObjectID, DIAMOND_CUBE_MASS, DiamondCubeObjectID, DIAMOND_AXE_MASS, DiamondAxeObjectID, DIAMOND_MASS, DiamondObjectID, DiamondOreObjectID, COTTON_BLOCK_MASS, CottonBlockObjectID, CottonObjectID, COBBLESTONE_BRICK_MASS, CobblestoneBrickObjectID, CobblestoneObjectID, ChestObjectID, CHEST_MASS, ClayShinglesObjectID, CLAY_SHINGLES_MASS, CLAY_POLISHED_MASS, ClayPolishedObjectID, CLAY_CARVED_MASS, ClayCarvedObjectID, CLAY_BRICK_MASS, ClayBrickObjectID, DirtObjectID, ClayObjectID, CLAY_MASS, MuckshroomObjectID, BellflowerObjectID, BlueMushroomSporeObjectID, BLUE_MUSHROOM_SPORE_MASS, BirchLogObjectID, ReinforcedBirchLumberObjectID, REINFORCED_BIRCH_LUMBER_MASS, BirchLumberObjectID, SilverOreObjectID, BIRCH_LUMBER_MASS, OakLogObjectID, OakLumberObjectID, OAK_LUMBER_MASS, BASALT_BRICK_MASS, BASALT_CARVED_MASS, BASALT_POLISHED_MASS, BASALT_SHINGLES_MASS, WoodenPickObjectID, WOODEN_PICK_MASS, BasaltObjectID, PaperObjectID, BasaltBrickObjectID, BasaltCarvedObjectID, BasaltPolishedObjectID, BasaltShinglesObjectID, PAPER_MASS } from "@tenet-world/src/Constants.sol";
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


    // recipeLimestoneBrick

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = LimestoneObjectID; // Defined earlier
    inputObjectTypeIds[1] = PaperObjectID; // Defined earlier
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Limestone
    inputObjectTypeAmounts[1] = 1; // 1 Paper

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = LimestoneBrickObjectID; // TODO: Define LimestoneBrickObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Limestone Brick

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = LIMESTONE_BRICK_MASS; // TODO: Define LIMESTONE_BRICK_MASS
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

    // recipeLimestoneCarved

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = LimestoneBrickObjectID; // From Limestone Brick recipe
    inputObjectTypeIds[1] = PaperObjectID; // Defined earlier
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Limestone Brick
    inputObjectTypeAmounts[1] = 1; // 1 Paper

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = LimestoneCarvedObjectID; // TODO: Define LimestoneCarvedObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Limestone Carved

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = LIMESTONE_CARVED_MASS; // TODO: Define LIMESTONE_CARVED_MASS
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

    // recipeLimestonePolished

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = LimestoneBrickObjectID; // From Limestone Brick recipe
    inputObjectTypeIds[1] = PaperObjectID; // Defined earlier
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Limestone Brick
    inputObjectTypeAmounts[1] = 1; // 1 Paper

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = LimestonePolishedObjectID; // TODO: Define LimestonePolishedObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Limestone Polished

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = LIMESTONE_POLISHED_MASS; // TODO: Define LIMESTONE_POLISHED_MASS
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

    // recipeLimestoneShingles

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = LimestoneBrickObjectID; // From Limestone Brick recipe
    inputObjectTypeIds[1] = PaperObjectID; // Defined earlier
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Limestone Brick
    inputObjectTypeAmounts[1] = 1; // 1 Paper

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = LimestoneShinglesObjectID; // TODO: Define LimestoneShinglesObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Limestone Shingles

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = LIMESTONE_SHINGLES_MASS; // TODO: Define LIMESTONE_SHINGLES_MASS
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

    // recipeMoonstone

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = QuartziteObjectID; // Defined earlier
    inputObjectTypeIds[1] = CoalOreObjectID; // Assuming this represents "coal nuggets"
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Quartzite
    inputObjectTypeAmounts[1] = 4; // 4 Coal Nuggets

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = MoonstoneObjectID; // Defined earlier
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Moonstone

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = MOONSTONE_MASS; // Defined earlier
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

    // recipeMushroomLeatherBlock

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = RedMushroomObjectID; // TODO: Define RedMushroomObjectID
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 4; // 4 Red Mushroom

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = MushroomLeatherBlockObjectID; // TODO: Define MushroomLeatherBlockObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Mushroom Leather Block

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = MUSHROOM_LEATHER_BLOCK_MASS; // TODO: Define MUSHROOM_LEATHER_BLOCK_MASS
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

    // recipeNeptuniumBar

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = NeptuniumOreObjectID; // Assuming this represents "neptunium nugget"
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 4; // 4 Neptunium Nugget

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = NeptuniumBarObjectID; // TODO: Define NeptuniumBarObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Neptunium Bar

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = NEPTUNIUM_BAR_MASS; // TODO: Define NEPTUNIUM_BAR_MASS
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

    // recipeNeptuniumCube

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = NeptuniumBarObjectID; // From Neptunium Bar recipe
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 8; // 8 Neptunium Bar

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = NeptuniumCubeObjectID; // TODO: Define NeptuniumCubeObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Neptunium Cube

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = NEPTUNIUM_CUBE_MASS; // TODO: Define NEPTUNIUM_CUBE_MASS
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


    // recipeNeptuniumAxe

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = NeptuniumBarObjectID; // From Neptunium Bar recipe
    inputObjectTypeIds[1] = OakLogObjectID; // Assuming OakLogObjectID for "log", adjust if necessary
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Neptunium Bar
    inputObjectTypeAmounts[1] = 4; // 4 Log

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = NeptuniumAxeObjectID; // TODO: Define NeptuniumAxeObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Neptunium Axe

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = NEPTUNIUM_AXE_MASS; // TODO: Define NEPTUNIUM_AXE_MASS
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

    // recipeNeptuniumPick

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = NeptuniumBarObjectID; // From Neptunium Bar recipe
    inputObjectTypeIds[1] = OakLogObjectID; // Assuming OakLogObjectID for "log", adjust if necessary
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Neptunium Bar
    inputObjectTypeAmounts[1] = 4; // 4 Log

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = NeptuniumPickObjectID; // TODO: Define NeptuniumPickObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Neptunium Pick

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = NEPTUNIUM_PICK_MASS; // TODO: Define NEPTUNIUM_PICK_MASS
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