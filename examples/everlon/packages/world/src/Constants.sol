// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { REGISTRY_ADDRESS } from "@tenet-base-world/src/Constants.sol";

address constant SIMULATOR_ADDRESS = 0x5FbDB2315678afecb367f032d93F642f64180aa3;

uint256 constant NUM_MAX_OBJECTS_INTERACTION_RUN = 1000;
uint256 constant NUM_MAX_UNIQUE_OBJECT_EVENT_HANDLERS_RUN = 15;
uint256 constant NUM_MAX_SAME_OBJECT_EVENT_HANDLERS_RUN = 25;
int32 constant NUM_MAX_AGENT_ACTION_RADIUS = 5;

uint8 constant NUM_BLOCK_STACKABLE = 99;

bytes32 constant AirObjectID = bytes32(keccak256("air"));
bytes32 constant SnowObjectID = bytes32(keccak256("snow"));
bytes32 constant AsphaltObjectID = bytes32(keccak256("asphalt"));
bytes32 constant BasaltObjectID = bytes32(keccak256("basalt"));
bytes32 constant ClayBrickObjectID = bytes32(keccak256("clay-brick"));
bytes32 constant CottonObjectID = bytes32(keccak256("cotton"));
bytes32 constant StoneObjectID = bytes32(keccak256("stone"));
bytes32 constant EmberstoneObjectID = bytes32(keccak256("emberstone"));
bytes32 constant CobblestoneObjectID = bytes32(keccak256("cobblestone"));
bytes32 constant MoonstoneObjectID = bytes32(keccak256("moonstone"));
bytes32 constant GraniteObjectID = bytes32(keccak256("granite"));
bytes32 constant QuartziteObjectID = bytes32(keccak256("quartzite"));
bytes32 constant LimestoneObjectID = bytes32(keccak256("limestone"));
bytes32 constant SunstoneObjectID = bytes32(keccak256("sunstone"));
bytes32 constant SoilObjectID = bytes32(keccak256("soil"));
bytes32 constant GravelObjectID = bytes32(keccak256("gravel"));
bytes32 constant ClayObjectID = bytes32(keccak256("clay"));
bytes32 constant BedrockObjectID = bytes32(keccak256("bedrock"));
bytes32 constant LavaObjectID = bytes32(keccak256("lava"));
bytes32 constant DiamondOreObjectID = bytes32(keccak256("diamond-ore"));
bytes32 constant GoldOreObjectID = bytes32(keccak256("gold-ore"));
bytes32 constant CoalOreObjectID = bytes32(keccak256("coal-ore"));
bytes32 constant SilverOreObjectID = bytes32(keccak256("silver-ore"));
bytes32 constant NeptuniumOreObjectID = bytes32(keccak256("neptunium-ore"));
bytes32 constant GrassObjectID = bytes32(keccak256("grass"));
bytes32 constant MuckGrassObjectID = bytes32(keccak256("muck-grass"));
bytes32 constant DirtObjectID = bytes32(keccak256("dirt"));
bytes32 constant MuckDirtObjectID = bytes32(keccak256("muck-dirt"));
bytes32 constant MossObjectID = bytes32(keccak256("moss"));
bytes32 constant CottonBushObjectID = bytes32(keccak256("cotton-bush"));
bytes32 constant MossGrassObjectID = bytes32(keccak256("moss-grass"));
bytes32 constant SwitchGrassObjectID = bytes32(keccak256("switch-grass"));
bytes32 constant OakLogObjectID = bytes32(keccak256("oak-log"));
bytes32 constant OakLumberObjectID = bytes32(keccak256("oak-lumber"));
bytes32 constant BirchLogObjectID = bytes32(keccak256("birch-log"));
bytes32 constant SakuraLogObjectID = bytes32(keccak256("sakura-log"));
bytes32 constant RubberLogObjectID = bytes32(keccak256("rubber-log"));
bytes32 constant OakLeafObjectID = bytes32(keccak256("oak-leaf"));
bytes32 constant BirchLeafObjectID = bytes32(keccak256("birch-leaf"));
bytes32 constant SakuraLeafObjectID = bytes32(keccak256("sakura-leaf"));
bytes32 constant RubberLeafObjectID = bytes32(keccak256("rubber-leaf"));

// Agents
bytes32 constant BuilderObjectID = bytes32(keccak256("builder"));
bytes32 constant FaucetObjectID = bytes32(keccak256("faucet"));
bytes32 constant RunnerObjectID = bytes32(keccak256("runner"));

uint256 constant PLAYER_MASS = 10;

uint256 constant AIR_MASS = 0;
uint256 constant SOIL_MASS = 3;
uint256 constant GRAVEL_MASS = 5;
uint256 constant CLAY_MASS = 6;
uint256 constant LAVA_MASS = 2;
uint256 constant BEDROCK_MASS = 1000;
uint256 constant MOSS_GRASS_MASS = 1;
uint256 constant SWITCH_GRASS_MASS = 1;
uint256 constant COTTON_BUSH_MASS = 1;
uint256 constant MOSS_MASS = 4;
uint256 constant MUCK_GRASS_MASS = 4;
uint256 constant GRASS_MASS = 4;
uint256 constant MUCK_DIRT_MASS = 4;
uint256 constant DIRT_MASS = 4;

uint256 constant COAL_ORE_MASS = 7;
uint256 constant SILVER_ORE_MASS = 9;
uint256 constant GOLD_ORE_MASS = 10;
uint256 constant DIAMOND_ORE_MASS = 15;
uint256 constant NEPTUNIUM_ORE_MASS = 20;

uint256 constant SNOW_MASS = 1;
uint256 constant ASPHALT_MASS = 8;
uint256 constant BASALT_MASS = 9;
uint256 constant CLAY_BRICK_MASS = 8;
uint256 constant COTTON_MASS = 1;

uint256 constant STONE_MASS = 7;
uint256 constant COBBLESTONE_MASS = 7;
uint256 constant GRANITE_MASS = 11;
uint256 constant LIMESTONE_MASS = 7;

uint256 constant EMBERSTONE_MASS = 15;
uint256 constant MOONSTONE_MASS = 15;
uint256 constant QUARTZITE_MASS = 10;
uint256 constant SUNSTONE_MASS = 15;

uint256 constant OAK_LOG_MASS = 4;
uint256 constant BIRCH_LOG_MASS = 4;
uint256 constant SAKURA_LOG_MASS = 4;
uint256 constant RUBBER_LOG_MASS = 4;

uint256 constant OAK_LUMBER_MASS = 4;

uint256 constant OAK_LEAF_MASS = 1;
uint256 constant BIRCH_LEAF_MASS = 1;
uint256 constant SAKURA_LEAF_MASS = 1;
uint256 constant RUBBER_LEAF_MASS = 1;

// Terrain
enum Biome {
  Mountains,
  Desert,
  Forest,
  Savanna
}

int32 constant STRUCTURE_CHUNK = 5;
int32 constant STRUCTURE_CHUNK_CENTER = STRUCTURE_CHUNK / 2 + 1;
