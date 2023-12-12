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

struct InterfaceVoxel {
  uint256 index;
  bytes32 entityId;
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
  // To get the real coords of each object in this base creation, add this offset to the relative coord of each object

  VoxelCoord[] deletedRelativeCoords; // the coord relative to this BASE creation, not to the creation this base creation is in
  // Why store deleted coords? Cause it's more space-efficient to store the deleted coords than all the voxels in the creation
  // Also in the future, this could be a "diffs" array.
}
