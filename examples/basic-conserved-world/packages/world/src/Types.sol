// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";

struct BuildWorldEventData {
  VoxelEntity agentEntity;
}

struct ActivateWorldEventData {
  VoxelEntity agentEntity;
}

struct MoveWorldEventData {
  VoxelEntity agentEntity;
}

struct MineWorldEventData {
  VoxelEntity agentEntity;
}

struct FluxEventData {
  uint256 massToFlux;
  uint256 energyToFlux;
  VoxelCoord energyReceiver;
}
