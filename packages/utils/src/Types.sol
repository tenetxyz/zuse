// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// Shared types between contracts

struct VoxelCoord {
  int32 x;
  int32 y;
  int32 z;
}

enum CoordDirection {
  X,
  Y,
  Z
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

enum SimTable {
  None,
  Mass,
  Energy,
  Velocity,
  Health,
  Stamina
}

struct ObjectProperties {
  uint256 mass;
  uint256 energy;
  uint256 lastUpdateBlock;
  bytes velocity;
  uint256 health;
  bool hasHealth;
  uint256 stamina;
  bool hasStamina;
}

struct CombatMoveData {
  ElementType moveType;
  uint256 stamina;
  bytes32 toObjectEntityId;
}

struct DecisionRule {
  bytes creationMetadata;
  address decisionRuleAddress;
  bytes4 decisionRuleSelector;
}

struct Mind {
  bytes creationMetadata;
  address mindAddress;
  bytes4 mindSelector;
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
