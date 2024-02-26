// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { REGISTRY_ADDRESS } from "@tenet-base-world/src/Constants.sol";

address constant SIMULATOR_ADDRESS = 0x322813Fd9A801c5507c9de605d63CEA4f2CE6c44;

uint256 constant NUM_MAX_OBJECTS_INTERACTION_RUN = 1000;
uint256 constant NUM_MAX_UNIQUE_OBJECT_EVENT_HANDLERS_RUN = 15;
uint256 constant NUM_MAX_SAME_OBJECT_EVENT_HANDLERS_RUN = 25;
int32 constant NUM_MAX_AGENT_ACTION_RADIUS = 5;

uint8 constant NUM_BLOCK_STACKABLE = 99;

uint256 constant MAX_CHEST_SLOTS = 12;

bytes32 constant AirObjectID = bytes32(keccak256("air"));
bytes32 constant SnowObjectID = bytes32(keccak256("snow"));
bytes32 constant AsphaltObjectID = bytes32(keccak256("asphalt"));
bytes32 constant BasaltObjectID = bytes32(keccak256("basalt"));
bytes32 constant PaperObjectID = bytes32(keccak256("paper"));
bytes32 constant BasaltBrickObjectID = bytes32(keccak256("basalt-brick"));
bytes32 constant BasaltCarvedObjectID = bytes32(keccak256("basalt-carved"));
bytes32 constant BasaltPolishedObjectID = bytes32(keccak256("basalt-polished"));
bytes32 constant BasaltShinglesObjectID = bytes32(keccak256("basalt-shingles"));
bytes32 constant ClayBrickObjectID = bytes32(keccak256("clay-brick"));
bytes32 constant ClayCarvedObjectID = bytes32(keccak256("clay-carved"));
bytes32 constant ClayPolishedObjectID = bytes32(keccak256("clay-polished"));
bytes32 constant ClayShinglesObjectID = bytes32(keccak256("clay-shingles"));
bytes32 constant CottonObjectID = bytes32(keccak256("cotton"));
bytes32 constant CottonBlockObjectID = bytes32(keccak256("cotton-block"));
bytes32 constant StoneObjectID = bytes32(keccak256("stone"));
bytes32 constant StoneAxeObjectID = bytes32(keccak256("stone-axe"));
bytes32 constant StonePickObjectID = bytes32(keccak256("stone-pick"));
bytes32 constant StoneWhackerObjectID = bytes32(keccak256("stone-pick"));
bytes32 constant StoneShinglesObjectID = bytes32(keccak256("stone-shingles"));
bytes32 constant PolishedStoneObjectID = bytes32(keccak256("polished-stone"));
bytes32 constant StoneCarvedObjectID = bytes32(keccak256("stone-carved"));
bytes32 constant StoneBrickObjectID = bytes32(keccak256("stone-brick"));
bytes32 constant RubbleObjectID = bytes32(keccak256("rubble"));
bytes32 constant EmberstoneObjectID = bytes32(keccak256("emberstone"));
bytes32 constant CobblestoneObjectID = bytes32(keccak256("cobblestone"));
bytes32 constant MoonstoneObjectID = bytes32(keccak256("moonstone"));
bytes32 constant GraniteObjectID = bytes32(keccak256("granite"));
bytes32 constant QuartziteObjectID = bytes32(keccak256("quartzite"));
bytes32 constant QuartziteBrickObjectID = bytes32(keccak256("quartzite-brick"));
bytes32 constant QuartziteCarvedObjectID = bytes32(keccak256("quartzite-carved"));
bytes32 constant QuartzitePolishedObjectID = bytes32(keccak256("quartzite-polished"));
bytes32 constant QuartziteShinglesObjectID = bytes32(keccak256("quartzite-shingles"));
bytes32 constant LimestoneObjectID = bytes32(keccak256("limestone"));
bytes32 constant LimestoneBrickObjectID = bytes32(keccak256("limestone-brick"));
bytes32 constant LimestoneCarvedObjectID = bytes32(keccak256("limestone-carved"));
bytes32 constant LimestonePolishedObjectID = bytes32(keccak256("limestone-polished"));
bytes32 constant LimestoneShinglesObjectID = bytes32(keccak256("limestone-shingles"));
bytes32 constant SunstoneObjectID = bytes32(keccak256("sunstone"));
bytes32 constant SoilObjectID = bytes32(keccak256("soil"));
bytes32 constant SandObjectID = bytes32(keccak256("sand"));
bytes32 constant GlassObjectID = bytes32(keccak256("glass"));
bytes32 constant GravelObjectID = bytes32(keccak256("gravel"));
bytes32 constant ClayObjectID = bytes32(keccak256("clay"));
bytes32 constant BedrockObjectID = bytes32(keccak256("bedrock"));
bytes32 constant LavaObjectID = bytes32(keccak256("lava"));
bytes32 constant DiamondOreObjectID = bytes32(keccak256("diamond-ore"));
bytes32 constant DiamondObjectID = bytes32(keccak256("diamond"));
bytes32 constant GoldOreObjectID = bytes32(keccak256("gold-ore"));
bytes32 constant GoldBarObjectID = bytes32(keccak256("gold-bar"));
bytes32 constant GoldCubeObjectID = bytes32(keccak256("gold-cube"));
bytes32 constant GoldAxeObjectID = bytes32(keccak256("gold-axe"));
bytes32 constant GoldPickObjectID = bytes32(keccak256("gold-pick"));
bytes32 constant NeptuniumAxeObjectID = bytes32(keccak256("neptunium-axe"));
bytes32 constant NeptuniumPickObjectID = bytes32(keccak256("neptunium-pick"));
bytes32 constant CoalOreObjectID = bytes32(keccak256("coal-ore"));
bytes32 constant SilverOreObjectID = bytes32(keccak256("silver-ore"));
bytes32 constant SilverBarObjectID = bytes32(keccak256("silver-ore"));
bytes32 constant SilverCubeObjectID = bytes32(keccak256("silver-cube"));
bytes32 constant SilverAxeObjectID = bytes32(keccak256("silver-axe"));
bytes32 constant SilverPickObjectID = bytes32(keccak256("silver-pick"));
bytes32 constant SilverWhackerObjectID = bytes32(keccak256("silver-whacker"));
bytes32 constant NeptuniumOreObjectID = bytes32(keccak256("neptunium-ore"));
bytes32 constant NeptuniumBarObjectID = bytes32(keccak256("neptunium-bar"));
bytes32 constant NeptuniumCubeObjectID = bytes32(keccak256("neptunium-cube"));
bytes32 constant GrassObjectID = bytes32(keccak256("grass"));
bytes32 constant HempObjectID = bytes32(keccak256("hemp"));
bytes32 constant LilacObjectID = bytes32(keccak256("lilac"));
bytes32 constant DandelionObjectID = bytes32(keccak256("dandelion"));
bytes32 constant MuckGrassObjectID = bytes32(keccak256("muck-grass"));
bytes32 constant MuckshroomObjectID = bytes32(keccak256("muckshroom"));
bytes32 constant RedMushroomObjectID = bytes32(keccak256("red-mushroom"));
bytes32 constant RedMushroomSporesObjectID = bytes32(keccak256("red-mushroom-spores"));
bytes32 constant MushroomLeatherBlockObjectID = bytes32(keccak256("mushroom-leather"));
bytes32 constant BellflowerObjectID = bytes32(keccak256("bellflower"));
bytes32 constant BlueMushroomSporeObjectID = bytes32(keccak256("blue-mushroom-spore"));
bytes32 constant DirtObjectID = bytes32(keccak256("dirt"));
bytes32 constant MuckDirtObjectID = bytes32(keccak256("muck-dirt"));
bytes32 constant MossObjectID = bytes32(keccak256("moss"));
bytes32 constant CottonBushObjectID = bytes32(keccak256("cotton-bush"));
bytes32 constant MossGrassObjectID = bytes32(keccak256("moss-grass"));
bytes32 constant SwitchGrassObjectID = bytes32(keccak256("switch-grass"));
bytes32 constant OakLogObjectID = bytes32(keccak256("oak-log"));
bytes32 constant OakLumberObjectID = bytes32(keccak256("oak-lumber"));
bytes32 constant MuckshroomSporesObjectID = bytes32(keccak256("muckshroom-spores"));
bytes32 constant ReinforcedOakLumberObjectID = bytes32(keccak256("reinforced-oak-lumber"));
bytes32 constant SakuraLumberObjectID = bytes32(keccak256("sakura-lumber"));
bytes32 constant RubberLogObjectID = bytes32(keccak256("rubber-log"));
bytes32 constant RubberLumberObjectID = bytes32(keccak256("rubber-lumber"));
bytes32 constant ReinforcedRubberLumberObjectID = bytes32(keccak256("reinforced-rubber-lumber"));
bytes32 constant GraniteBrickObjectID = bytes32(keccak256("granite-brick"));
bytes32 constant GraniteCarvedObjectID = bytes32(keccak256("granite-carved"));
bytes32 constant GraniteShinglesObjectID = bytes32(keccak256("granite-shingles"));
bytes32 constant GranitePolishedObjectID = bytes32(keccak256("granite-polished"));
bytes32 constant BirchLogObjectID = bytes32(keccak256("birch-log"));
bytes32 constant BirchLumberObjectID = bytes32(keccak256("birch-lumber"));
bytes32 constant ReinforcedBirchLumberObjectID = bytes32(keccak256("reinforced-birch-lumber"));
bytes32 constant SakuraLogObjectID = bytes32(keccak256("sakura-log"));
bytes32 constant OakLeafObjectID = bytes32(keccak256("oak-leaf"));
bytes32 constant BirchLeafObjectID = bytes32(keccak256("birch-leaf"));
bytes32 constant SakuraLeafObjectID = bytes32(keccak256("sakura-leaf"));
bytes32 constant RubberLeafObjectID = bytes32(keccak256("rubber-leaf"));
bytes32 constant DaylilyObjectID = bytes32(keccak256("daylily"));
bytes32 constant AzaleaObjectID = bytes32(keccak256("azalea"));
bytes32 constant RoseObjectID = bytes32(keccak256("rose"));
bytes32 constant ChestObjectID = bytes32(keccak256("chest"));
bytes32 constant ThermoblasterObjectID = bytes32(keccak256("thermoblaster"));
bytes32 constant WorkbenchObjectID = bytes32(keccak256("workbench"));
bytes32 constant DyeomaticObjectID = bytes32(keccak256("dye-o-matic"));
bytes32 constant CobblestoneBrickObjectID = bytes32(keccak256("cobblestone-brick"));
bytes32 constant WoodenPickObjectID = bytes32(keccak256("wooden-pick"));
bytes32 constant WoodenAxeObjectID = bytes32(keccak256("wooden-axe"));
bytes32 constant WoodenWhackerObjectID = bytes32(keccak256("wooden-whacker"));
bytes32 constant DiamondAxeObjectID = bytes32(keccak256("diamond-axe"));
bytes32 constant DiamondPickObjectID = bytes32(keccak256("diamond-axe"));
bytes32 constant DiamondCubeObjectID = bytes32(keccak256("diamond-cube"));
bytes32 constant BlueDyeObjectID = bytes32(keccak256("blue-dye"));
bytes32 constant BrownDyeObjectID = bytes32(keccak256("brown-dye"));
bytes32 constant GreenDyeObjectID = bytes32(keccak256("green-dye"));
bytes32 constant MagentaDyeObjectID = bytes32(keccak256("magenta-dye"));
bytes32 constant OrangeDyeObjectID = bytes32(keccak256("orange-dye"));
bytes32 constant PinkDyeObjectID = bytes32(keccak256("pink-dye"));
bytes32 constant PurpleDyeObjectID = bytes32(keccak256("purple-dye"));
bytes32 constant RedDyeObjectID = bytes32(keccak256("red-dye"));
bytes32 constant TanDyeObjectID = bytes32(keccak256("tan-dye"));
bytes32 constant WhiteDyeObjectID = bytes32(keccak256("white-dye"));
bytes32 constant YellowDyeObjectID = bytes32(keccak256("yellow-dye"));
bytes32 constant BlackDyeObjectID = bytes32(keccak256("black-dye"));
bytes32 constant SilverDyeObjectID = bytes32(keccak256("silver-dye"));

bytes32 constant BlueOakLumberObjectID = bytes32(keccak256("blue-oak-lumber"));
bytes32 constant BrownOakLumberObjectID = bytes32(keccak256("brown-oak-lumber"));
bytes32 constant GreenOakLumberObjectID = bytes32(keccak256("green-oak-lumber"));
bytes32 constant MagentaOakLumberObjectID = bytes32(keccak256("magenta-oak-lumber"));
bytes32 constant OrangeOakLumberObjectID = bytes32(keccak256("orange-oak-lumber"));
bytes32 constant PinkOakLumberObjectID = bytes32(keccak256("pink-oak-lumber"));
bytes32 constant PurpleOakLumberObjectID = bytes32(keccak256("purple-oak-lumber"));
bytes32 constant RedOakLumberObjectID = bytes32(keccak256("red-oak-lumber"));
bytes32 constant TanOakLumberObjectID = bytes32(keccak256("tan-oak-lumber"));
bytes32 constant WhiteOakLumberObjectID = bytes32(keccak256("white-oak-lumber"));
bytes32 constant YellowOakLumberObjectID = bytes32(keccak256("yellow-oak-lumber"));
bytes32 constant BlackOakLumberObjectID = bytes32(keccak256("black-oak-lumber"));
bytes32 constant SilverOakLumberObjectID = bytes32(keccak256("silver-oak-lumber"));

bytes32 constant BlueCottonBlockObjectID = bytes32(keccak256("blue-cotton-block"));
bytes32 constant BrownCottonBlockObjectID = bytes32(keccak256("brown-cotton-block"));
bytes32 constant GreenCottonBlockObjectID = bytes32(keccak256("green-cotton-block"));
bytes32 constant MagentaCottonBlockObjectID = bytes32(keccak256("magenta-cotton-block"));
bytes32 constant OrangeCottonBlockObjectID = bytes32(keccak256("orange-cotton-block"));
bytes32 constant PinkCottonBlockObjectID = bytes32(keccak256("pink-cotton-block"));
bytes32 constant PurpleCottonBlockObjectID = bytes32(keccak256("purple-cotton-block"));
bytes32 constant RedCottonBlockObjectID = bytes32(keccak256("red-cotton-block"));
bytes32 constant TanCottonBlockObjectID = bytes32(keccak256("tan-cotton-block"));
bytes32 constant WhiteCottonBlockObjectID = bytes32(keccak256("white-cotton-block"));
bytes32 constant YellowCottonBlockObjectID = bytes32(keccak256("yellow-cotton-block"));
bytes32 constant BlackCottonBlockObjectID = bytes32(keccak256("black-cotton-block"));
bytes32 constant SilverCottonBlockObjectID = bytes32(keccak256("silver-cotton-block"));

bytes32 constant BlueGlassObjectID = bytes32(keccak256("blue-glass"));
bytes32 constant BrownGlassObjectID = bytes32(keccak256("brown-glass"));
bytes32 constant GreenGlassObjectID = bytes32(keccak256("green-glass"));
bytes32 constant MagentaGlassObjectID = bytes32(keccak256("magenta-glass"));
bytes32 constant OrangeGlassObjectID = bytes32(keccak256("orange-glass"));
bytes32 constant PinkGlassObjectID = bytes32(keccak256("pink-glass"));
bytes32 constant PurpleGlassObjectID = bytes32(keccak256("purple-glass"));
bytes32 constant RedGlassObjectID = bytes32(keccak256("red-glass"));
bytes32 constant TanGlassObjectID = bytes32(keccak256("tan-glass"));
bytes32 constant WhiteGlassObjectID = bytes32(keccak256("white-glass"));
bytes32 constant YellowGlassObjectID = bytes32(keccak256("yellow-glass"));
bytes32 constant BlackGlassObjectID = bytes32(keccak256("black-glass"));
bytes32 constant SilverGlassObjectID = bytes32(keccak256("silver-glass"));


// Agents
bytes32 constant BuilderObjectID = bytes32(keccak256("builder"));
bytes32 constant FaucetObjectID = bytes32(keccak256("faucet"));
bytes32 constant RunnerObjectID = bytes32(keccak256("runner"));

uint256 constant PLAYER_MASS = 10;

uint256 constant AIR_MASS = 0;
uint256 constant SOIL_MASS = 3;
uint256 constant GRAVEL_MASS = 5;
uint256 constant CLAY_MASS = 16;
uint256 constant LAVA_MASS = 2;
uint256 constant BEDROCK_MASS = 1000;
uint256 constant MOSS_GRASS_MASS = 1;
uint256 constant SWITCH_GRASS_MASS = 1;
uint256 constant COTTON_BUSH_MASS = 1;
uint256 constant MOSS_MASS = 4;
uint256 constant MUCK_GRASS_MASS = 4;
uint256 constant GRASS_MASS = 4;
uint256 constant HEMP_MASS = 1;
uint256 constant LILAC_MASS = 1;
uint256 constant DANDELION_MASS = 1;
uint256 constant ROSE_MASS = 1;
uint256 constant DAYLILY_MASS = 1;
uint256 constant AZALEA_MASS = 1;

uint256 constant MUCK_DIRT_MASS = 4;
uint256 constant DIRT_MASS = 4;

uint256 constant COAL_ORE_MASS = 7;
uint256 constant SILVER_ORE_MASS = 9;
uint256 constant SILVER_BAR_MASS = 36; //9*4 = 36
uint256 constant SILVER_CUBE_MASS = 288; //36*8 = 288
uint256 constant SILVER_AXE_MASS = 160; //36*4 + 4*4 = 160
uint256 constant SILVER_PICK_MASS = 160; //36*4 + 4*4 = 160
uint256 constant SILVER_WHACKER_MASS = 216; //36*6 = 216

uint256 constant GOLD_ORE_MASS = 10;
uint256 constant GOLD_BAR_MASS = 40;
uint256 constant GOLD_CUBE_MASS = 320;
uint256 constant GOLD_AXE_MASS = 176;
uint256 constant GOLD_PICK_MASS = 176;

uint256 constant DIAMOND_ORE_MASS = 15;
uint256 constant DIAMOND_MASS = 60;
uint256 constant DIAMOND_CUBE_MASS = 480; //60 * 8 = 480

uint256 constant NEPTUNIUM_ORE_MASS = 20;
uint256 constant NEPTUNIUM_BAR_MASS = 80;
uint256 constant NEPTUNIUM_CUBE_MASS = 640; //80 * 8 = 640

uint256 constant SNOW_MASS = 1;
uint256 constant ASPHALT_MASS = 8;
uint256 constant BASALT_MASS = 9;
uint256 constant COTTON_MASS = 1;
uint256 constant SAND_MASS = 2;
uint256 constant GLASS_MASS = 11;

uint256 constant STONE_MASS = 7;
uint256 constant STONE_AXE_MASS = 72; //56 + 16 = 72
uint256 constant STONE_PICK_MASS = 72; //56 + 16 = 72
uint256 constant STONE_WHACKER_MASS = 36; //7*4 + 4*2 = 36

uint256 constant POLISHED_STONE_MASS = 7;
uint256 constant STONE_CARVED_MASS = 7;
uint256 constant STONE_BRICK_MASS = 7;
uint256 constant STONE_SHINGLES_MASS = 7;

uint256 constant RUBBLE_MASS = 2;
uint256 constant COBBLESTONE_MASS = 7;
uint256 constant GRANITE_MASS = 11;
uint256 constant GRANITE_BRICK_MASS = 11;
uint256 constant GRANITE_CARVED_MASS = 11;
uint256 constant GRANITE_POLISHED_MASS = 11;
uint256 constant GRANITE_SHINGLES_MASS = 11;

uint256 constant LIMESTONE_MASS = 7;
uint256 constant LIMESTONE_BRICK_MASS = 7;
uint256 constant LIMESTONE_CARVED_MASS = 7;
uint256 constant LIMESTONE_POLISHED_MASS = 7;
uint256 constant LIMESTONE_SHINGLES_MASS = 7;

uint256 constant EMBERSTONE_MASS = 14; 
uint256 constant QUARTZITE_MASS = 10;

uint256 constant QUARTZITE_BRICK_MASS = 10;
uint256 constant QUARTZITE_CARVED_MASS = 10;
uint256 constant QUARTZITE_POLISHED_MASS = 10;
uint256 constant QUARTZITE_SHINGLES_MASS = 10;

uint256 constant SUNSTONE_MASS = 14;
uint256 constant MOONSTONE_MASS = 17;

uint256 constant OAK_LOG_MASS = 4;
uint256 constant BIRCH_LOG_MASS = 4;
uint256 constant SAKURA_LOG_MASS = 4;
uint256 constant SAKURA_LUMBER_MASS = 1;

uint256 constant RUBBER_LOG_MASS = 4;

uint256 constant RUBBER_LUMBER_MASS = 1;
uint256 constant REINFORCED_RUBBER_LUMBER_MASS = 3;

uint256 constant OAK_LUMBER_MASS = 1;
uint256 constant REINFORCED_OAK_LUMBER_MASS = 3;

uint256 constant BIRCH_LUMBER_MASS = 1;

uint256 constant OAK_LEAF_MASS = 1;
uint256 constant BIRCH_LEAF_MASS = 1;
uint256 constant SAKURA_LEAF_MASS = 1;
uint256 constant RUBBER_LEAF_MASS = 1;

uint256 constant CHEST_MASS = 24;
uint256 constant THERMOBLASTER_MASS = 63; //7 * 9 = 63
uint256 constant WORKBENCH_MASS = 20; //4 * 5 = 20
uint256 constant DYE_O_MATIC_MASS = 68; 

uint256 constant BLUE_OAK_LUMBER_MASS = 2;
uint256 constant BROWN_OAK_LUMBER_MASS = 2;
uint256 constant GREEN_OAK_LUMBER_MASS = 2;
uint256 constant MAGENTA_OAK_LUMBER_MASS = 2;
uint256 constant ORANGE_OAK_LUMBER_MASS = 2;
uint256 constant PINK_OAK_LUMBER_MASS = 2;
uint256 constant PURPLE_OAK_LUMBER_MASS = 2;
uint256 constant RED_OAK_LUMBER_MASS = 2;
uint256 constant TAN_OAK_LUMBER_MASS = 2;
uint256 constant WHITE_OAK_LUMBER_MASS = 2;
uint256 constant YELLOW_OAK_LUMBER_MASS = 2;
uint256 constant BLACK_OAK_LUMBER_MASS = 2;
uint256 constant SILVER_OAK_LUMBER_MASS = 2;

uint256 constant BLUE_COTTON_BLOCK_MASS = 5;
uint256 constant BROWN_COTTON_BLOCK_MASS = 5;
uint256 constant GREEN_COTTON_BLOCK_MASS = 5;
uint256 constant MAGENTA_COTTON_BLOCK_MASS = 5;
uint256 constant ORANGE_COTTON_BLOCK_MASS = 5;
uint256 constant PINK_COTTON_BLOCK_MASS = 5;
uint256 constant PURPLE_COTTON_BLOCK_MASS = 5;
uint256 constant RED_COTTON_BLOCK_MASS = 5;
uint256 constant TAN_COTTON_BLOCK_MASS = 5;
uint256 constant WHITE_COTTON_BLOCK_MASS = 5;
uint256 constant YELLOW_COTTON_BLOCK_MASS = 5;
uint256 constant BLACK_COTTON_BLOCK_MASS = 5;
uint256 constant SILVER_COTTON_BLOCK_MASS = 5;

uint256 constant BLUE_GLASS_MASS = 5;
uint256 constant BROWN_GLASS_MASS = 5;
uint256 constant GREEN_GLASS_MASS = 5;
uint256 constant MAGENTA_GLASS_MASS = 5;
uint256 constant ORANGE_GLASS_MASS = 5;
uint256 constant PINK_GLASS_MASS = 5;
uint256 constant PURPLE_GLASS_MASS = 5;
uint256 constant RED_GLASS_MASS = 5;
uint256 constant TAN_GLASS_MASS = 5;
uint256 constant WHITE_GLASS_MASS = 5;
uint256 constant YELLOW_GLASS_MASS = 5;
uint256 constant BLACK_GLASS_MASS = 5;
uint256 constant SILVER_GLASS_MASS = 5;

uint256 constant WOODEN_PICK_MASS = 16;
uint256 constant WOODEN_AXE_MASS = 16;
uint256 constant WOODEN_WHACKER_MASS = 32;

uint256 constant DIAMOND_AXE_MASS = 196;
uint256 constant DIAMOND_PICK_MASS = 196;

uint256 constant NEPTUNIUM_AXE_MASS = 336;
uint256 constant NEPTUNIUM_PICK_MASS = 336;

uint256 constant PAPER_MASS = 1;
uint256 constant BASALT_BRICK_MASS = 10;
uint256 constant BASALT_CARVED_MASS = 11;
uint256 constant BASALT_POLISHED_MASS = 11;
uint256 constant BASALT_SHINGLES_MASS = 11;

uint256 constant REINFORCED_BIRCH_LUMBER_MASS = 3;

uint256 constant MUCKSHROOM_MASS = 1;
uint256 constant MUCKSHROOM_SPORES_MASS = 6;

uint256 constant BELLFLOWER_MASS = 1;

uint256 constant BLUE_DYE_MASS = 1;
uint256 constant BROWN_DYE_MASS = 1;
uint256 constant GREEN_DYE_MASS = 1;
uint256 constant MAGENTA_DYE_MASS = 1;
uint256 constant ORANGE_DYE_MASS = 1;
uint256 constant PINK_DYE_MASS = 1;
uint256 constant PURPLE_DYE_MASS = 1;
uint256 constant RED_DYE_MASS = 1;
uint256 constant TAN_DYE_MASS = 1;
uint256 constant WHITE_DYE_MASS = 1;
uint256 constant YELLOW_DYE_MASS = 1;
uint256 constant BLACK_DYE_MASS = 1;
uint256 constant SILVER_DYE_MASS = 1;

uint256 constant BLUE_MUSHROOM_SPORE_MASS = 5;

uint256 constant RED_MUSHROOM = 2;
uint256 constant RED_MUSHROOM_SPORES_MASS = 1; 

uint256 constant MUSHROOM_LEATHER_BLOCK_MASS = 8;

uint256 constant CLAY_BRICK_MASS = 16;
uint256 constant CLAY_CARVED_MASS = 16;
uint256 constant CLAY_POLISHED_MASS = 16;
uint256 constant CLAY_SHINGLES_MASS = 16;

uint256 constant COBBLESTONE_BRICK_MASS = 7;
uint256 constant COTTON_BLOCK_MASS = 4;

// Terrain
enum Biome {
  Mountains,
  Desert,
  Forest,
  Savanna
}

int32 constant STRUCTURE_CHUNK = 5;
int32 constant STRUCTURE_CHUNK_CENTER = STRUCTURE_CHUNK / 2 + 1;
