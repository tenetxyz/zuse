// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelEntity } from "@tenet-utils/src/Types.sol";

struct BuildWorldEventData {
  VoxelEntity agentEntity;
}

struct ActivateWorldEventData {
  VoxelEntity agentEntity;
}

struct MoveWorldEventData {
  VoxelEntity agentEntity;
}