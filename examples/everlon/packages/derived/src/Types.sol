// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { CreatureData } from "@tenet-creatures/src/codegen/tables/Creature.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

struct PlantDataWithEntity {
  VoxelCoord coord;
  uint256 totalProduced;
}

struct CreatureDataWithEntity {
  CreatureData creatureData;
  bytes32 objectEntityId;
}
