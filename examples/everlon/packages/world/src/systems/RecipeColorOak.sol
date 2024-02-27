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
import { BlueOakLumberObjectID, BLUE_OAK_LUMBER_MASS,
BrownOakLumberObjectID, BROWN_OAK_LUMBER_MASS,
GreenOakLumberObjectID, GREEN_OAK_LUMBER_MASS,
MagentaOakLumberObjectID, MAGENTA_OAK_LUMBER_MASS,
OrangeOakLumberObjectID, ORANGE_OAK_LUMBER_MASS,
PinkOakLumberObjectID, PINK_OAK_LUMBER_MASS,
PurpleOakLumberObjectID, PURPLE_OAK_LUMBER_MASS,
RedOakLumberObjectID, RED_OAK_LUMBER_MASS,
TanOakLumberObjectID, TAN_OAK_LUMBER_MASS,
WhiteOakLumberObjectID, WHITE_OAK_LUMBER_MASS,
YellowOakLumberObjectID, YELLOW_OAK_LUMBER_MASS,
BlackOakLumberObjectID, BLACK_OAK_LUMBER_MASS,
SilverOakLumberObjectID, SILVER_OAK_LUMBER_MASS,
    DandelionObjectID, RoseObjectID, LilacObjectID, PinkDyeObjectID, PINK_DYE_MASS, PurpleDyeObjectID, PURPLE_DYE_MASS, RedDyeObjectID, RED_DYE_MASS, TanDyeObjectID, TAN_DYE_MASS, WhiteDyeObjectID, WHITE_DYE_MASS, YellowDyeObjectID, YELLOW_DYE_MASS, BlackDyeObjectID, BLACK_DYE_MASS, SilverDyeObjectID, SILVER_DYE_MASS, AzaleaObjectID, OrangeDyeObjectID, ORANGE_DYE_MASS, DaylilyObjectID, LilacObjectID, HempObjectID, BlueDyeObjectID, BLUE_DYE_MASS, BrownDyeObjectID, BROWN_DYE_MASS, GreenDyeObjectID, GREEN_DYE_MASS, MagentaDyeObjectID, MAGENTA_DYE_MASS, OrangeDyeObjectID, ORANGE_DYE_MASS, StoneShinglesObjectID, STONE_SHINGLES_MASS, POLISHED_STONE_MASS, STONE_CARVED_MASS, STONE_BRICK_MASS, PolishedStoneObjectID, StoneCarvedObjectID, StoneBrickObjectID, StoneWhackerObjectID, STONE_WHACKER_MASS, StonePickObjectID, STONE_PICK_MASS, StoneAxeObjectID, STONE_AXE_MASS, WoodenWhackerObjectID, WOODEN_WHACKER_MASS, WoodenAxeObjectID, WOODEN_AXE_MASS, SunstoneObjectID, SUNSTONE_MASS, SilverWhackerObjectID, SILVER_WHACKER_MASS, SilverPickObjectID, SILVER_PICK_MASS, SilverAxeObjectID, SILVER_AXE_MASS, SilverCubeObjectID, SILVER_CUBE_MASS, SILVER_BAR_MASS, SilverBarObjectID, SakuraLogObjectID, SakuraLumberObjectID, SAKURA_LUMBER_MASS, RubbleObjectID, RUBBLE_MASS, ReinforcedRubberLumberObjectID, REINFORCED_RUBBER_LUMBER_MASS, RubberLogObjectID, RUBBER_LUMBER_MASS, RedMushroomSporesObjectID, RED_MUSHROOM_SPORES_MASS, QuartziteShinglesObjectID, QUARTZITE_SHINGLES_MASS, QuartzitePolishedObjectID, QUARTZITE_POLISHED_MASS, QuartziteCarvedObjectID, QUARTZITE_CARVED_MASS, QuartziteBrickObjectID, QUARTZITE_BRICK_MASS, MuckshroomSporesObjectID, MUCKSHROOM_SPORES_MASS, ReinforcedOakLumberObjectID, REINFORCED_OAK_LUMBER_MASS, NeptuniumPickObjectID, MOONSTONE_MASS, NeptuniumAxeObjectID, NEPTUNIUM_AXE_MASS, NEPTUNIUM_PICK_MASS, NeptuniumCubeObjectID, NEPTUNIUM_CUBE_MASS, NeptuniumOreObjectID, NEPTUNIUM_BAR_MASS, NeptuniumBarObjectID, RedMushroomObjectID, MushroomLeatherBlockObjectID, MUSHROOM_LEATHER_BLOCK_MASS, MoonstoneObjectID, QuartziteObjectID, LIMESTONE_CARVED_MASS, LIMESTONE_SHINGLES_MASS, LIMESTONE_POLISHED_MASS, LimestoneShinglesObjectID, LimestonePolishedObjectID, LimestoneCarvedObjectID, LimestoneObjectID, LimestoneBrickObjectID, LIMESTONE_BRICK_MASS, GRANITE_SHINGLES_MASS, GraniteShinglesObjectID, GranitePolishedObjectID, GRANITE_POLISHED_MASS, GRANITE_CARVED_MASS, GraniteCarvedObjectID, GRANITE_BRICK_MASS, GraniteBrickObjectID, GraniteObjectID, SakuraLumberObjectID, RubberLumberObjectID, GoldPickObjectID, GOLD_PICK_MASS, GoldAxeObjectID, GOLD_AXE_MASS, GOLD_CUBE_MASS, GoldCubeObjectID, GOLD_BAR_MASS, GoldBarObjectID, GoldOreObjectID, GlassObjectID, GLASS_MASS, SandObjectID, EMBERSTONE_MASS, EmberstoneObjectID, StoneObjectID, CoalOreObjectID, DIAMOND_PICK_MASS, DiamondPickObjectID, DIAMOND_CUBE_MASS, DiamondCubeObjectID, DIAMOND_AXE_MASS, DiamondAxeObjectID, DIAMOND_MASS, DiamondObjectID, DiamondOreObjectID, COTTON_BLOCK_MASS, CottonBlockObjectID, CottonObjectID, COBBLESTONE_BRICK_MASS, CobblestoneBrickObjectID, CobblestoneObjectID, ChestObjectID, CHEST_MASS, ClayShinglesObjectID, CLAY_SHINGLES_MASS, CLAY_POLISHED_MASS, ClayPolishedObjectID, CLAY_CARVED_MASS, ClayCarvedObjectID, CLAY_BRICK_MASS, ClayBrickObjectID, DirtObjectID, ClayObjectID, CLAY_MASS, MuckshroomObjectID, BellflowerObjectID, BlueMushroomSporeObjectID, BLUE_MUSHROOM_SPORE_MASS, BirchLogObjectID, ReinforcedBirchLumberObjectID, REINFORCED_BIRCH_LUMBER_MASS, BirchLumberObjectID, SilverOreObjectID, BIRCH_LUMBER_MASS, OakLogObjectID, OakLumberObjectID, OAK_LUMBER_MASS, BASALT_BRICK_MASS, BASALT_CARVED_MASS, BASALT_POLISHED_MASS, BASALT_SHINGLES_MASS, WoodenPickObjectID, WOODEN_PICK_MASS, BasaltObjectID, PaperObjectID, BasaltBrickObjectID, BasaltCarvedObjectID, BasaltPolishedObjectID, BasaltShinglesObjectID, PAPER_MASS } from "@tenet-world/src/Constants.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";


contract RecipeColorOak is System {
  function initRecipeColorOak() public {
    
    // recipeBlueOakLumber

    bytes32[] memory inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = OakLumberObjectID;
    inputObjectTypeIds[1] = BlueDyeObjectID;
    uint8[] memory inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 1; // 1 Oak Lumber
    inputObjectTypeAmounts[1] = 1; // 1 Blue Dye

    bytes32[] memory outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = BlueOakLumberObjectID; // TODO: Define BlueOakLumberObjectID
    uint8[] memory outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Blue Oak Lumber

    ObjectProperties[] memory outputObjectProperties = new ObjectProperties[](1);
    ObjectProperties memory outputOutputProperties;
    outputOutputProperties.mass = BLUE_OAK_LUMBER_MASS; // TODO: Define BLUE_OAK_LUMBER_MASS
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

    // recipeBrownOakLumber

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = OakLumberObjectID;
    inputObjectTypeIds[1] = BrownDyeObjectID; // Assuming BrownDyeObjectID is defined
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 1; // 1 Oak Lumber
    inputObjectTypeAmounts[1] = 1; // 1 Brown Dye

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = BrownOakLumberObjectID; // TODO: Define BrownOakLumberObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Brown Oak Lumber

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = BROWN_OAK_LUMBER_MASS; // TODO: Define BROWN_OAK_LUMBER_MASS
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

    // recipeGreenOakLumber

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = OakLumberObjectID;
    inputObjectTypeIds[1] = GreenDyeObjectID; // Assuming GreenDyeObjectID is defined
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 1; // 1 Oak Lumber
    inputObjectTypeAmounts[1] = 1; // 1 Green Dye

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = GreenOakLumberObjectID; // TODO: Define GreenOakLumberObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Green Oak Lumber

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = GREEN_OAK_LUMBER_MASS; // TODO: Define GREEN_OAK_LUMBER_MASS
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

    // recipeMagentaOakLumber

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = OakLumberObjectID;
    inputObjectTypeIds[1] = MagentaDyeObjectID; // Assuming MagentaDyeObjectID is defined
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 1; // 1 Oak Lumber
    inputObjectTypeAmounts[1] = 1; // 1 Magenta Dye

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = MagentaOakLumberObjectID; // TODO: Define MagentaOakLumberObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Magenta Oak Lumber

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = MAGENTA_OAK_LUMBER_MASS; // TODO: Define MAGENTA_OAK_LUMBER_MASS
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

    // recipeOrangeOakLumber

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = OakLumberObjectID;
    inputObjectTypeIds[1] = OrangeDyeObjectID; // Assuming OrangeDyeObjectID is defined
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 1; // 1 Oak Lumber
    inputObjectTypeAmounts[1] = 1; // 1 Orange Dye

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = OrangeOakLumberObjectID; // TODO: Define OrangeOakLumberObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Orange Oak Lumber

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = ORANGE_OAK_LUMBER_MASS; // TODO: Define ORANGE_OAK_LUMBER_MASS
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

    // recipePinkOakLumber

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = OakLumberObjectID;
    inputObjectTypeIds[1] = PinkDyeObjectID; // Assuming PinkDyeObjectID is defined
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 1; // 1 Oak Lumber
    inputObjectTypeAmounts[1] = 1; // 1 Pink Dye

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = PinkOakLumberObjectID; // TODO: Define PinkOakLumberObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Pink Oak Lumber

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = PINK_OAK_LUMBER_MASS; // TODO: Define PINK_OAK_LUMBER_MASS
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


    // recipePurpleOakLumber

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = OakLumberObjectID;
    inputObjectTypeIds[1] = PurpleDyeObjectID; // Assuming PurpleDyeObjectID is defined
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 1; // 1 Oak Lumber
    inputObjectTypeAmounts[1] = 1; // 1 Purple Dye

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = PurpleOakLumberObjectID; // TODO: Define PurpleOakLumberObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Purple Oak Lumber

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = PURPLE_OAK_LUMBER_MASS; // TODO: Define PURPLE_OAK_LUMBER_MASS
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

    // recipeRedOakLumber

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = OakLumberObjectID;
    inputObjectTypeIds[1] = RedDyeObjectID; // Assuming RedDyeObjectID is defined
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 1; // 1 Oak Lumber
    inputObjectTypeAmounts[1] = 1; // 1 Red Dye

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = RedOakLumberObjectID; // TODO: Define RedOakLumberObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Red Oak Lumber

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = RED_OAK_LUMBER_MASS; // TODO: Define RED_OAK_LUMBER_MASS
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

    // recipeTanOakLumber

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = OakLumberObjectID;
    inputObjectTypeIds[1] = TanDyeObjectID; // TODO: Define TanDyeObjectID
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 1; // 1 Oak Lumber
    inputObjectTypeAmounts[1] = 1; // 1 Tan Dye

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = TanOakLumberObjectID; // TODO: Define TanOakLumberObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Tan Oak Lumber

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = TAN_OAK_LUMBER_MASS; // TODO: Define TAN_OAK_LUMBER_MASS
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

    // recipeWhiteOakLumber

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = OakLumberObjectID;
    inputObjectTypeIds[1] = WhiteDyeObjectID; // TODO: Define WhiteDyeObjectID
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 1; // 1 Oak Lumber
    inputObjectTypeAmounts[1] = 1; // 1 White Dye

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = WhiteOakLumberObjectID; // TODO: Define WhiteOakLumberObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 White Oak Lumber

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = WHITE_OAK_LUMBER_MASS; // TODO: Define WHITE_OAK_LUMBER_MASS
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

    // recipeYellowOakLumber

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = OakLumberObjectID;
    inputObjectTypeIds[1] = YellowDyeObjectID; // TODO: Define YellowDyeObjectID
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 1; // 1 Oak Lumber
    inputObjectTypeAmounts[1] = 1; // 1 Yellow Dye

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = YellowOakLumberObjectID; // TODO: Define YellowOakLumberObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Yellow Oak Lumber

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = YELLOW_OAK_LUMBER_MASS; // TODO: Define YELLOW_OAK_LUMBER_MASS
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

    // recipeBlackOakLumber

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = OakLumberObjectID;
    inputObjectTypeIds[1] = BlackDyeObjectID; // TODO: Define BlackDyeObjectID
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 1; // 1 Oak Lumber
    inputObjectTypeAmounts[1] = 1; // 1 Black Dye

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = BlackOakLumberObjectID; // TODO: Define BlackOakLumberObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Black Oak Lumber

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = BLACK_OAK_LUMBER_MASS; // TODO: Define BLACK_OAK_LUMBER_MASS
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

    // recipeSilverOakLumber

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = OakLumberObjectID;
    inputObjectTypeIds[1] = SilverDyeObjectID; // TODO: Define SilverDyeObjectID
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 1; // 1 Oak Lumber
    inputObjectTypeAmounts[1] = 1; // 1 Silver Dye

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = SilverOakLumberObjectID; // TODO: Define SilverOakLumberObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Silver Oak Lumber

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = SILVER_OAK_LUMBER_MASS; // TODO: Define SILVER_OAK_LUMBER_MASS
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