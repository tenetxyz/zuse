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
import { SilverWhackerObjectID, SILVER_WHACKER_MASS, SilverPickObjectID, SILVER_PICK_MASS, SilverAxeObjectID, SILVER_AXE_MASS, SilverCubeObjectID, SILVER_CUBE_MASS, SILVER_BAR_MASS, SilverBarObjectID, SakuraLogObjectID, SakuraLumberObjectID, SAKURA_LUMBER_MASS, RubbleObjectID, RUBBLE_MASS, ReinforcedRubberLumberObjectID, REINFORCED_RUBBER_LUMBER_MASS, RubberLogObjectID, RUBBER_LUMBER_MASS, RedMushroomSporesObjectID, RED_MUSHROOM_SPORES_MASS, QuartziteShinglesObjectID, QUARTZITE_SHINGLES_MASS, QuartzitePolishedObjectID, QUARTZITE_POLISHED_MASS, QuartziteCarvedObjectID, QUARTZITE_CARVED_MASS, QuartziteBrickObjectID, QUARTZITE_BRICK_MASS, MuckshroomSporesObjectID, MUCKSHROOM_SPORES_MASS, ReinforcedOakLumberObjectID, REINFORCED_OAK_LUMBER_MASS, NeptuniumPickObjectID, MOONSTONE_MASS, NeptuniumAxeObjectID, NEPTUNIUM_AXE_MASS, NEPTUNIUM_PICK_MASS, NeptuniumCubeObjectID, NEPTUNIUM_CUBE_MASS, NeptuniumOreObjectID, NEPTUNIUM_BAR_MASS, NeptuniumBarObjectID, RedMushroomObjectID, MushroomLeatherBlockObjectID, MUSHROOM_LEATHER_BLOCK_MASS, MoonstoneObjectID, QuartziteObjectID, LIMESTONE_CARVED_MASS, LIMESTONE_SHINGLES_MASS, LIMESTONE_POLISHED_MASS, LimestoneShinglesObjectID, LimestonePolishedObjectID, LimestoneCarvedObjectID, LimestoneObjectID, LimestoneBrickObjectID, LIMESTONE_BRICK_MASS, GRANITE_SHINGLES_MASS, GraniteShinglesObjectID, GranitePolishedObjectID, GRANITE_POLISHED_MASS, GRANITE_CARVED_MASS, GraniteCarvedObjectID, GRANITE_BRICK_MASS, GraniteBrickObjectID, GraniteObjectID, SakuraLumberObjectID, RubberLumberObjectID, GoldPickObjectID, GOLD_PICK_MASS, GoldAxeObjectID, GOLD_AXE_MASS, GOLD_CUBE_MASS, GoldCubeObjectID, GOLD_BAR_MASS, GoldBarObjectID, GoldOreObjectID, GlassObjectID, GLASS_MASS, SandObjectID, EMBERSTONE_MASS, EmberstoneObjectID, StoneObjectID, CoalOreObjectID, DIAMOND_PICK_MASS, DiamondPickObjectID, DIAMOND_CUBE_MASS, DiamondCubeObjectID, DIAMOND_AXE_MASS, DiamondAxeObjectID, DIAMOND_MASS, DiamondObjectID, DiamondOreObjectID, COTTON_BLOCK_MASS, CottonBlockObjectID, CottonObjectID, COBBLESTONE_BRICK_MASS, CobblestoneBrickObjectID, CobblestoneObjectID, ChestObjectID, CHEST_MASS, ClayShinglesObjectID, CLAY_SHINGLES_MASS, CLAY_POLISHED_MASS, ClayPolishedObjectID, CLAY_CARVED_MASS, ClayCarvedObjectID, CLAY_BRICK_MASS, ClayBrickObjectID, DirtObjectID, ClayObjectID, CLAY_MASS, MuckshroomObjectID, BellflowerObjectID, BlueMushroomSporeObjectID, BLUE_MUSHROOM_SPORE_MASS, BirchLogObjectID, ReinforcedBirchLumberObjectID, REINFORCED_BIRCH_LUMBER_MASS, BirchLumberObjectID, SilverOreObjectID, BIRCH_LUMBER_MASS, OakLogObjectID, OakLumberObjectID, OAK_LUMBER_MASS, BASALT_BRICK_MASS, BASALT_CARVED_MASS, BASALT_POLISHED_MASS, BASALT_SHINGLES_MASS, WoodenPickObjectID, WOODEN_PICK_MASS, BasaltObjectID, PaperObjectID, BasaltBrickObjectID, BasaltCarvedObjectID, BasaltPolishedObjectID, BasaltShinglesObjectID, PAPER_MASS } from "@tenet-world/src/Constants.sol";
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

    // recipeOakReinforced

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = OakLumberObjectID; // Assuming OakLumberObjectID is defined
    inputObjectTypeIds[1] = SilverOreObjectID; // Assuming SilverOreObjectID for "silver nugget", adjust if different
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Oak Lumber
    inputObjectTypeAmounts[1] = 1; // 1 Silver Nugget

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = ReinforcedOakLumberObjectID; // TODO: Define ReinforcedOakLumberObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Reinforced Oak Lumber

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = REINFORCED_OAK_LUMBER_MASS; // TODO: Define mass for Reinforced Oak Lumber
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

    // recipePurifyMuckshroom

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = MuckshroomObjectID; // Assuming MuckshroomObjectID is defined
    inputObjectTypeIds[1] = OakLumberObjectID; // TODO: Define LumberObjectID if using generic lumber instead of a specific type
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 2; // 2 Muckshroom
    inputObjectTypeAmounts[1] = 4; // 4 Lumber

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = MuckshroomSporesObjectID; // TODO: Define MuckshroomSporesObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Muckshroom Spores

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = MUCKSHROOM_SPORES_MASS; // TODO: Define mass for Muckshroom Spores
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

    // recipeQuartziteBrick

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = QuartziteObjectID; // Defined earlier
    inputObjectTypeIds[1] = PaperObjectID; // Defined earlier
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Quartzite
    inputObjectTypeAmounts[1] = 1; // 1 Paper

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = QuartziteBrickObjectID; // TODO: Define QuartziteBrickObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Quartzite Brick

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = QUARTZITE_BRICK_MASS; // TODO: Define QUARTZITE_BRICK_MASS
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

    // recipeQuartziteCarved

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = QuartziteBrickObjectID; // From Quartzite Brick recipe
    inputObjectTypeIds[1] = PaperObjectID; // Defined earlier
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Quartzite Brick
    inputObjectTypeAmounts[1] = 1; // 1 Paper

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = QuartziteCarvedObjectID; // TODO: Define QuartziteCarvedObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Quartzite Carved

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = QUARTZITE_CARVED_MASS; // TODO: Define QUARTZITE_CARVED_MASS
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

    // recipeQuartzitePolished

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = QuartziteBrickObjectID; // TODO: Ensure QuartziteBrickObjectID is defined
    inputObjectTypeIds[1] = PaperObjectID; // Defined earlier
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Quartzite Brick
    inputObjectTypeAmounts[1] = 1; // 1 Paper

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = QuartzitePolishedObjectID; // TODO: Define QuartzitePolishedObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Quartzite Polished

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = QUARTZITE_POLISHED_MASS; // TODO: Define QUARTZITE_POLISHED_MASS
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

    // recipeQuartziteShingles

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = QuartziteBrickObjectID; // TODO: Ensure QuartziteBrickObjectID is defined
    inputObjectTypeIds[1] = PaperObjectID; // Defined earlier
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Quartzite Brick
    inputObjectTypeAmounts[1] = 1; // 1 Paper

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = QuartziteShinglesObjectID; // TODO: Define QuartziteShinglesObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Quartzite Shingles

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = QUARTZITE_SHINGLES_MASS; // TODO: Define QUARTZITE_SHINGLES_MASS
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

    // recipeRedMushroomSpores

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = RedMushroomObjectID; // Assuming RedMushroomObjectID is defined
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 2; // 2 Red Mushroom

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = RedMushroomSporesObjectID; // TODO: Define RedMushroomSporesObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Red Mushroom Spores

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = RED_MUSHROOM_SPORES_MASS; // TODO: Define mass for Red Mushroom Spores
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

    // recipeRubberLumber

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = RubberLogObjectID; // Assuming RubberLogObjectID is defined
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 1; // 1 Rubber Log

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = RubberLumberObjectID; // TODO: Define RubberLumberObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Rubber Lumber

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = RUBBER_LUMBER_MASS; // TODO: Define mass for Rubber Lumber
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

    // recipeRubberReinforced

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = RubberLumberObjectID; // From Rubber Lumber recipe
    inputObjectTypeIds[1] = SilverOreObjectID; // Assuming SilverOreObjectID represents "silver nugget"
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Rubber Lumber
    inputObjectTypeAmounts[1] = 1; // 1 Silver Nugget

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = ReinforcedRubberLumberObjectID; // TODO: Define ReinforcedRubberLumberObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Reinforced Rubber Lumber

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = REINFORCED_RUBBER_LUMBER_MASS; // TODO: Define mass for Reinforced Rubber Lumber
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

    // recipeRubble

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = StoneObjectID; // Defined earlier
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 1; // 1 Stone

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = RubbleObjectID; // TODO: Define RubbleObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Rubble

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = RUBBLE_MASS; // TODO: Define mass for Rubble
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

    // recipeSakuraLumber

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = SakuraLogObjectID; // Assuming SakuraLogObjectID is defined
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 1; // 1 Sakura Log

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = SakuraLumberObjectID; // TODO: Define SakuraLumberObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Sakura Lumber

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = SAKURA_LUMBER_MASS; // TODO: Define mass for Sakura Lumber
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

    // recipeSilverBar

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = SilverOreObjectID; // Assuming SilverOreObjectID represents "silver nugget"
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 4; // 4 Silver Nugget

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = SilverBarObjectID; // TODO: Define SilverBarObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Silver Bar

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = SILVER_BAR_MASS; // TODO: Define SILVER_BAR_MASS
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













  }
}