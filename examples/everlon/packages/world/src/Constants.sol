// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0x057ef64E23666F000b34aE31332854aCBd1c8544;
address constant SIMULATOR_ADDRESS = 0x5FbDB2315678afecb367f032d93F642f64180aa3;

uint256 constant NUM_MAX_OBJECTS_INTERACTION_RUN = 1000;
uint256 constant NUM_MAX_UNIQUE_OBJECT_EVENT_HANDLERS_RUN = 15;
uint256 constant NUM_MAX_SAME_OBJECT_EVENT_HANDLERS_RUN = 25;
uint256 constant NUM_MAX_AGENT_ACTION_RADIUS = 10;

int32 constant SHARD_DIM = 100;

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

uint256 constant AIR_MASS = 0;
uint256 constant SIMPLE_LIGHT_BLOCK_MASS = 2;
uint256 constant SIMPLE_BLOCK_MASS = 5;
uint256 constant BEDROCK_MASS = 50;

// Terrain
enum Biome {
  Mountains,
  Desert,
  Forest,
  Savanna
}

int32 constant STRUCTURE_CHUNK = 5;
int32 constant STRUCTURE_CHUNK_CENTER = STRUCTURE_CHUNK / 2 + 1;
