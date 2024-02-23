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
import { OrangeDyeObjectID, ORANGE_DYE_MASS, DaylilyObjectID, LilacObjectID, HempObjectID, BlueDyeObjectID, BLUE_DYE_MASS, BrownDyeObjectID, BROWN_DYE_MASS, GreenDyeObjectID, GREEN_DYE_MASS, MagentaDyeObjectID, MAGENTA_DYE_MASS, OrangeDyeObjectID, ORANGE_DYE_MASS, StoneShinglesObjectID, STONE_SHINGLES_MASS, POLISHED_STONE_MASS, STONE_CARVED_MASS, STONE_BRICK_MASS, PolishedStoneObjectID, StoneCarvedObjectID, StoneBrickObjectID, StoneWhackerObjectID, STONE_WHACKER_MASS, StonePickObjectID, STONE_PICK_MASS, StoneAxeObjectID, STONE_AXE_MASS, WoodenWhackerObjectID, WOODEN_WHACKER_MASS, WoodenAxeObjectID, WOODEN_AXE_MASS, SunstoneObjectID, SUNSTONE_MASS, SilverWhackerObjectID, SILVER_WHACKER_MASS, SilverPickObjectID, SILVER_PICK_MASS, SilverAxeObjectID, SILVER_AXE_MASS, SilverCubeObjectID, SILVER_CUBE_MASS, SILVER_BAR_MASS, SilverBarObjectID, SakuraLogObjectID, SakuraLumberObjectID, SAKURA_LUMBER_MASS, RubbleObjectID, RUBBLE_MASS, ReinforcedRubberLumberObjectID, REINFORCED_RUBBER_LUMBER_MASS, RubberLogObjectID, RUBBER_LUMBER_MASS, RedMushroomSporesObjectID, RED_MUSHROOM_SPORES_MASS, QuartziteShinglesObjectID, QUARTZITE_SHINGLES_MASS, QuartzitePolishedObjectID, QUARTZITE_POLISHED_MASS, QuartziteCarvedObjectID, QUARTZITE_CARVED_MASS, QuartziteBrickObjectID, QUARTZITE_BRICK_MASS, MuckshroomSporesObjectID, MUCKSHROOM_SPORES_MASS, ReinforcedOakLumberObjectID, REINFORCED_OAK_LUMBER_MASS, NeptuniumPickObjectID, MOONSTONE_MASS, NeptuniumAxeObjectID, NEPTUNIUM_AXE_MASS, NEPTUNIUM_PICK_MASS, NeptuniumCubeObjectID, NEPTUNIUM_CUBE_MASS, NeptuniumOreObjectID, NEPTUNIUM_BAR_MASS, NeptuniumBarObjectID, RedMushroomObjectID, MushroomLeatherBlockObjectID, MUSHROOM_LEATHER_BLOCK_MASS, MoonstoneObjectID, QuartziteObjectID, LIMESTONE_CARVED_MASS, LIMESTONE_SHINGLES_MASS, LIMESTONE_POLISHED_MASS, LimestoneShinglesObjectID, LimestonePolishedObjectID, LimestoneCarvedObjectID, LimestoneObjectID, LimestoneBrickObjectID, LIMESTONE_BRICK_MASS, GRANITE_SHINGLES_MASS, GraniteShinglesObjectID, GranitePolishedObjectID, GRANITE_POLISHED_MASS, GRANITE_CARVED_MASS, GraniteCarvedObjectID, GRANITE_BRICK_MASS, GraniteBrickObjectID, GraniteObjectID, SakuraLumberObjectID, RubberLumberObjectID, GoldPickObjectID, GOLD_PICK_MASS, GoldAxeObjectID, GOLD_AXE_MASS, GOLD_CUBE_MASS, GoldCubeObjectID, GOLD_BAR_MASS, GoldBarObjectID, GoldOreObjectID, GlassObjectID, GLASS_MASS, SandObjectID, EMBERSTONE_MASS, EmberstoneObjectID, StoneObjectID, CoalOreObjectID, DIAMOND_PICK_MASS, DiamondPickObjectID, DIAMOND_CUBE_MASS, DiamondCubeObjectID, DIAMOND_AXE_MASS, DiamondAxeObjectID, DIAMOND_MASS, DiamondObjectID, DiamondOreObjectID, COTTON_BLOCK_MASS, CottonBlockObjectID, CottonObjectID, COBBLESTONE_BRICK_MASS, CobblestoneBrickObjectID, CobblestoneObjectID, ChestObjectID, CHEST_MASS, ClayShinglesObjectID, CLAY_SHINGLES_MASS, CLAY_POLISHED_MASS, ClayPolishedObjectID, CLAY_CARVED_MASS, ClayCarvedObjectID, CLAY_BRICK_MASS, ClayBrickObjectID, DirtObjectID, ClayObjectID, CLAY_MASS, MuckshroomObjectID, BellflowerObjectID, BlueMushroomSporeObjectID, BLUE_MUSHROOM_SPORE_MASS, BirchLogObjectID, ReinforcedBirchLumberObjectID, REINFORCED_BIRCH_LUMBER_MASS, BirchLumberObjectID, SilverOreObjectID, BIRCH_LUMBER_MASS, OakLogObjectID, OakLumberObjectID, OAK_LUMBER_MASS, BASALT_BRICK_MASS, BASALT_CARVED_MASS, BASALT_POLISHED_MASS, BASALT_SHINGLES_MASS, WoodenPickObjectID, WOODEN_PICK_MASS, BasaltObjectID, PaperObjectID, BasaltBrickObjectID, BasaltCarvedObjectID, BasaltPolishedObjectID, BasaltShinglesObjectID, PAPER_MASS } from "@tenet-world/src/Constants.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";


contract RecipeSysDye is System {
  function initRecipeSysDye() public {

    // recipeBlueDye

    bytes32[] memory inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = BellflowerObjectID; // TODO: Define BellflowerObjectID
    uint8[] memory inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 10; // 10 Bellflower

    bytes32[] memory outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = BlueDyeObjectID; // TODO: Define BlueDyeObjectID
    uint8[] memory outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 10; // 10 Blue Dye

    ObjectProperties[] memory outputObjectProperties = new ObjectProperties[](1);
    ObjectProperties memory outputOutputProperties;
    outputOutputProperties.mass = BLUE_DYE_MASS; // TODO: Define BLUE_DYE_MASS
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

    // recipeBrownDye

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = SakuraLumberObjectID; // Defined earlier
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 10; // 10 Sakura Lumber

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = BrownDyeObjectID; // TODO: Define BrownDyeObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 10; // 16 Brown Dye

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = BROWN_DYE_MASS; // TODO: Define BROWN_DYE_MASS
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

    // recipeGreenDye

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = HempObjectID; 
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 10; // 10 Hemp

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = GreenDyeObjectID;
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 10; // 10 Green Dye

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = GREEN_DYE_MASS;
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

    // recipeMagentaDye

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = LilacObjectID; // TODO: Define LilacObjectID
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 10; // 10 Lilac

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = MagentaDyeObjectID; // TODO: Define MagentaDyeObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 10; // 10 Magenta Dye

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = MAGENTA_DYE_MASS; // TODO: Define MAGENTA_DYE_MASS
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

    // recipeOrangeDye

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = DaylilyObjectID; // TODO: Define DaylilyObjectID
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 10; // 12 Daylily

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = OrangeDyeObjectID; // TODO: Define OrangeDyeObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 10; // 10 Orange Dye

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = ORANGE_DYE_MASS; // TODO: Define ORANGE_DYE_MASS
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