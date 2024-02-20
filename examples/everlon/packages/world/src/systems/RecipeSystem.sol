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
import { GlassObjectID, GLASS_MASS, SandObjectID, EMBERSTONE_MASS, EmberstoneObjectID, StoneObjectID, CoalOreObjectID, DIAMOND_PICK_MASS, DiamondPickObjectID, DIAMOND_CUBE_MASS, DiamondCubeObjectID, DIAMOND_AXE_MASS, DiamondAxeObjectID, DIAMOND_MASS, DiamondObjectID, DiamondOreObjectID, COTTON_BLOCK_MASS, CottonBlockObjectID, CottonObjectID, COBBLESTONE_BRICK_MASS, CobblestoneBrickObjectID, CobblestoneObjectID, ChestObjectID, CHEST_MASS, ClayShinglesObjectID, CLAY_SHINGLES_MASS, CLAY_POLISHED_MASS, ClayPolishedObjectID, CLAY_CARVED_MASS, ClayCarvedObjectID, CLAY_BRICK_MASS, ClayBrickObjectID, DirtObjectID, ClayObjectID, CLAY_MASS, MuckshroomObjectID, BellflowerObjectID, BlueMushroomSporeObjectID, BLUE_MUSHROOM_SPORE_MASS, BirchLogObjectID, ReinforcedBirchLumberObjectID, REINFORCED_BIRCH_LUMBER_MASS, BirchLumberObjectID, SilverOreObjectID, BIRCH_LUMBER_MASS, OakLogObjectID, OakLumberObjectID, OAK_LUMBER_MASS, BASALT_BRICK_MASS, BASALT_CARVED_MASS, BASALT_POLISHED_MASS, BASALT_SHINGLES_MASS, WoodenPickObjectID, WOODEN_PICK_MASS, BasaltObjectID, PaperObjectID, BasaltBrickObjectID, BasaltCarvedObjectID, BasaltPolishedObjectID, BasaltShinglesObjectID, PAPER_MASS } from "@tenet-world/src/Constants.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

contract RecipeSystem is System {
  // TODO: Make this only callable once
  function initRecipes() public {
    // 1 Oak Log -> 4 Oak Lumber

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

    // Oak Log 4 -> 1 Wooden Pick

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


    // 24 Oak Lumber -> 1 Chest
    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = OakLumberObjectID;
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 24;

    // Recipe outputs
    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = ChestObjectID;
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1;
    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = CHEST_MASS;
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
    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = BasaltObjectID;
    inputObjectTypeIds[1] = PaperObjectID;
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4;
    inputObjectTypeAmounts[1] = 4;

    // Recipe outputs
    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = BasaltBrickObjectID;
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4;

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = BASALT_BRICK_MASS;
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

    // recipeBasaltCarved

    // Recipe inputs
    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = BasaltBrickObjectID;
    inputObjectTypeIds[1] = PaperObjectID;
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4;
    inputObjectTypeAmounts[1] = 4;

    // Recipe outputs
    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = BasaltCarvedObjectID;
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4;

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = BASALT_CARVED_MASS;
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

    // recipeBasaltPolished

    // Identical structure to recipeBasaltCarved, with adjusted output type
    // Recipe inputs
    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = BasaltBrickObjectID;
    inputObjectTypeIds[1] = PaperObjectID;
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4;
    inputObjectTypeAmounts[1] = 4;

    // Recipe outputs
    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = BasaltPolishedObjectID;
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4;

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = BASALT_POLISHED_MASS;
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
    
    // recipeBasaltShingles

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = BasaltBrickObjectID;
    inputObjectTypeIds[1] = PaperObjectID;
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4;
    inputObjectTypeAmounts[1] = 4;

    // Recipe outputs
    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = BasaltShinglesObjectID;
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4;

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = BASALT_SHINGLES_MASS;
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

    // recipePaper0

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = OakLogObjectID;
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 1;

    // Recipe outputs
    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = PaperObjectID;
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4;

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = PAPER_MASS;
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

    // recipeBirchLumber

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = BirchLogObjectID;
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 1;

    // Recipe outputs
    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = BirchLumberObjectID;
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4;

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = BIRCH_LUMBER_MASS;
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

    // recipeBirchReinforced

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = BirchLumberObjectID; // Adjust if there's a specific ID
    inputObjectTypeIds[1] = SilverOreObjectID;
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4;
    inputObjectTypeAmounts[1] = 1;

    // Recipe outputs
    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = ReinforcedBirchLumberObjectID; // Define this ID if not already defined
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4;

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = REINFORCED_BIRCH_LUMBER_MASS; // Define this mass if not already defined
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

    // recipeBlueMushroomSpores

    // Recipe inputs
    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = MuckshroomObjectID; // TODO: Define MuckshroomObjectID
    inputObjectTypeIds[1] = BellflowerObjectID; // TODO: Define BellflowerObjectID
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 3; // 3 Muckshroom
    inputObjectTypeAmounts[1] = 2; // 2 Bellflower

    // Recipe outputs
    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = BlueMushroomSporeObjectID; // TODO: Define BlueMushroomSporeObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Blue Mushroom Spore

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = BLUE_MUSHROOM_SPORE_MASS; // TODO: Define BLUE_MUSHROOM_SPORE_MASS and assign here
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


    // recipeClay

    // Recipe inputs
    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = DirtObjectID; // This is defined earlier, no TODO needed here
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 4; // 4 Dirt

    // Recipe outputs
    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = ClayObjectID; // This is defined earlier, no TODO needed here
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Clay

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = CLAY_MASS; // This is defined earlier, no TODO needed here
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


    // recipeClayBrick

    // Recipe inputs
    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = ClayObjectID; // Defined earlier
    inputObjectTypeIds[1] = PaperObjectID; // Defined earlier
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Clay
    inputObjectTypeAmounts[1] = 1; // 1 Paper

    // Recipe outputs
    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = ClayBrickObjectID; // Defined earlier
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Clay Brick

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = CLAY_BRICK_MASS; // Defined earlier
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

    // recipeClayCarved

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = ClayBrickObjectID; // Defined earlier
    inputObjectTypeIds[1] = PaperObjectID; // Defined earlier
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Clay Brick
    inputObjectTypeAmounts[1] = 1; // 1 Paper

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = ClayCarvedObjectID; // TODO: Define ClayCarvedObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Clay Carved

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = CLAY_CARVED_MASS; // TODO: Define CLAY_CARVED_MASS
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


    // recipeClayPolished

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = ClayBrickObjectID; // Defined earlier
    inputObjectTypeIds[1] = PaperObjectID; // Defined earlier
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Clay Brick
    inputObjectTypeAmounts[1] = 1; // 1 Paper

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = ClayPolishedObjectID; // TODO: Define ClayPolishedObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Clay Polished

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = CLAY_POLISHED_MASS; // TODO: Define CLAY_POLISHED_MASS
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


    // recipeClayShingles

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = ClayBrickObjectID; // Defined earlier
    inputObjectTypeIds[1] = PaperObjectID; // Defined earlier
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Clay Brick
    inputObjectTypeAmounts[1] = 1; // 1 Paper

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = ClayShinglesObjectID; // TODO: Define ClayShinglesObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Clay Shingles

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = CLAY_SHINGLES_MASS; // TODO: Define CLAY_SHINGLES_MASS
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

    // recipeCobblestoneBrick

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = CobblestoneObjectID; 
    inputObjectTypeIds[1] = PaperObjectID; 
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Rubble
    inputObjectTypeAmounts[1] = 1; // 1 Paper

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = CobblestoneBrickObjectID; // TODO: Define CobblestoneBrickObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Cobblestone Brick

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = COBBLESTONE_BRICK_MASS; // TODO: Define COBBLESTONE_BRICK_MASS
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

    // recipeCottonBlock

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = CottonObjectID; // Defined earlier
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 4; // 4 Cottonball

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = CottonBlockObjectID; // TODO: Define CottonBlockObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Cottonblock

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = COTTON_BLOCK_MASS; // TODO: Define COTTON_BLOCK_MASS
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

    // recipeDiamondGem

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = DiamondOreObjectID; 
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 4;

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = DiamondObjectID; // TODO: Define DiamondObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Diamond

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = DIAMOND_MASS; // TODO: Define DIAMOND_MASS
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

    // recipeDiamondAxe

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = DiamondObjectID; // TODO: Define DiamondObjectID if not defined
    inputObjectTypeIds[1] = OakLogObjectID; // Assuming OakLogObjectID for "log", adjust if necessary
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Diamond Gem
    inputObjectTypeAmounts[1] = 4; // 4 Log

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = DiamondAxeObjectID; // TODO: Define DiamondAxeObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Axe

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = DIAMOND_AXE_MASS; // TODO: Define DIAMOND_AXE_MASS
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

    // recipeDiamondCube

    inputObjectTypeIds = new bytes32[](1);
    inputObjectTypeIds[0] = DiamondObjectID;
    inputObjectTypeAmounts = new uint8[](1);
    inputObjectTypeAmounts[0] = 8; // 8 Diamond Gem

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = DiamondCubeObjectID; // TODO: Define DiamondCubeObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Diamond Cube

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = DIAMOND_CUBE_MASS; // TODO: Define DIAMOND_CUBE_MASS
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


    // recipeDiamondPick

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = DiamondObjectID; // TODO: Define DiamondObjectID if not defined
    inputObjectTypeIds[1] = OakLogObjectID; // Assuming OakLogObjectID for "log", adjust if necessary
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Diamond Gem
    inputObjectTypeAmounts[1] = 4; // 4 Log

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = DiamondPickObjectID; // TODO: Define DiamondPickObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Pick

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = DIAMOND_PICK_MASS; // TODO: Define DIAMOND_PICK_MASS
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

    // recipeEmberstone

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = CoalOreObjectID; // Assuming CoalOreObjectID for "coal nuggets", adjust if necessary
    inputObjectTypeIds[1] = StoneObjectID; // Defined earlier
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 4; // 4 Coal Nuggets
    inputObjectTypeAmounts[1] = 4; // 4 Stone

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = EmberstoneObjectID; // Defined earlier
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 4; // 4 Emberstone

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = EMBERSTONE_MASS; // Defined earlier
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

    // recipeGlass

    inputObjectTypeIds = new bytes32[](2);
    inputObjectTypeIds[0] = SandObjectID; // TODO: Define SandObjectID
    inputObjectTypeIds[1] = CoalOreObjectID; // Assuming CoalOreObjectID for "coal", adjust if necessary
    inputObjectTypeAmounts = new uint8[](2);
    inputObjectTypeAmounts[0] = 2; // 2 Sand
    inputObjectTypeAmounts[1] = 1; // 1 Coal

    outputObjectTypeIds = new bytes32[](1);
    outputObjectTypeIds[0] = GlassObjectID; // TODO: Define GlassObjectID
    outputObjectTypeAmounts = new uint8[](1);
    outputObjectTypeAmounts[0] = 1; // 1 Glass

    outputObjectProperties = new ObjectProperties[](1);
    outputOutputProperties.mass = GLASS_MASS; // TODO: Define GLASS_MASS
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
