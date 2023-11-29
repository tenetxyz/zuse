// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

struct VoxelEntity {
  uint32 scale;
  bytes32 entityId;
}

struct VoxelCoord {
  int32 x;
  int32 y;
  int32 z;
}

struct Coord {
  int32 x;
  int32 y;
}

struct Tuple {
  int128 x;
  int128 y;
}

// In 3D, there are 6 von Neumann neighbours
enum BlockDirection {
  None,
  North,
  South,
  East,
  West,
  Up,
  Down
}

enum ActionType {
  Transformation,
  Transfer
}

struct Action {
  ActionType actionType;
  SimTable senderTable;
  bytes senderValue;
  bytes32 targetObjectEntityId;
  VoxelCoord targetCoord;
  SimTable targetTable;
  bytes targetValue;
}

struct EntityActionData {
  bytes32 entityId;
  Action[] actions;
}

enum WorldEventType {
  Move
}

struct WorldEventData {
  WorldEventType eventType;
  VoxelCoord newCoord;
}

enum SimTable {
  None,
  Mass,
  Energy,
  Velocity,
  Health,
  Stamina,
  Element,
  CombatMove,
  Nutrients,
  Nitrogen,
  Phosphorus,
  Potassium,
  Elixir,
  Protein,
  Temperature
}

struct SimEventData {
  SimTable senderTable;
  bytes senderValue;
  VoxelEntity targetEntity;
  VoxelCoord targetCoord;
  SimTable targetTable;
  bytes targetValue;
}

enum CAEventType {
  None,
  WorldEvent,
  SimEvent,
  BatchSimEvent
}

struct CAEventData {
  CAEventType eventType;
  bytes eventData;
}

struct DecisionRuleKey {
  bytes32 srcVoxelTypeId;
  bytes32 targetVoxelTypeId;
  address worldAddress;
  bytes32 decisionRuleId;
}

struct DecisionRule {
  bytes32 decisionRuleId;
  bytes creationMetadata;
  bytes4 decisionRuleSelector;
}

struct Mind {
  bytes creationMetadata;
  bytes4 mindSelector;
}

struct InteractionSelector {
  bytes4 interactionSelector;
  string interactionName;
  string interactionDescription;
}

struct VoxelSelectors {
  bytes4 enterWorldSelector;
  bytes4 exitWorldSelector;
  bytes4 voxelVariantSelector;
  bytes4 activateSelector;
  bytes4 onNewNeighbourSelector;
  InteractionSelector[] interactionSelectors;
}

struct BlockHeightUpdate {
  uint256 blockNumber;
  uint256 blockHeightDelta;
  uint256 lastUpdateBlock;
}

struct VoxelTypeData {
  bytes32 voxelTypeId;
  bytes32 voxelVariantId;
}

enum EventType {
  Build,
  Mine,
  Activate,
  Move
}

enum ElementType {
  None,
  Fire,
  Water,
  Grass
}

struct ObjectProperties {
  uint256 mass;
  uint256 energy;
  uint256 lastUpdateBlock;
  bytes velocity;
  uint256 health;
  uint256 stamina;
  ElementType elementType;
  ActionData actionData;
  uint256 nutrients;
  uint256 nitrogen;
  bool hasNitrogen;
  uint256 phosphorus;
  bool hasPhosphorus;
  uint256 potassium;
  bool hasPotassium;
  uint256 elixir;
  uint256 protein;
  uint256 temperature;
}

enum ValueType {
  Int256,
  ElementType,
  VoxelCoord,
  VoxelCoordArray
}

struct ActionData {
  ElementType actionType;
  uint256 stamina;
  bytes actionEntity;
}

struct CreationSpawns {
  address worldAddress;
  uint256 numSpawns;
}

struct CreationMetadata {
  address creator;
  string name;
  string description;
  CreationSpawns[] spawns;
}

enum ComponentType {
  RANGE,
  STATE
}

struct ComponentDef {
  ComponentType componentType;
  string name;
  bytes definition; // RangeComponent or StateComponent
}

struct RangeComponent {
  int32 rangeStart;
  int32 rangeEnd;
}

struct StateComponent {
  string[] states;
}

struct InterfaceVoxel {
  uint256 index;
  VoxelEntity entity;
  string name;
  string desc;
}

struct BaseCreationInWorld {
  bytes32 creationId;
  VoxelCoord lowerSouthWestCornerInWorld;
  VoxelCoord[] deletedRelativeCoords; // the coord relative to the BASE creation, not to the creation this base creation is in
}

struct BaseCreation {
  bytes32 creationId;
  VoxelCoord coordOffset; // the offset of the base creation relative to the creation this base creation is in
  // To get the real coords of each voxel in this base creation, add this offset to the relative coord of each voxel

  VoxelCoord[] deletedRelativeCoords; // the coord relative to this BASE creation, not to the creation this base creation is in
  // Why store deleted coords? Cause it's more space-efficient to store the deleted coords than all the voxels in the creation
  // Also in the future, this could be a "diffs" array.
}

struct TerrainData {
  bytes32 voxelTypeId;
  uint256 energy;
}

struct TerrainSectionData {
  bool useExistingBlock;
  bytes32 voxelTypeId;
  uint256 energy;
  int32 xCorner;
  int32 yCorner;
  int32 zCorner;
  int32 xLength;
  int32 zLength;
  int32 yLength;
  bool includeAir;
}
