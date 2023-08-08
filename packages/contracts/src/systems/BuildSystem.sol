// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { BuildEvent } from "../prototypes/BuildEvent.sol";
import { VoxelCoord } from "../Types.sol";
import { WorldConfig, WorldConfigTableId, OwnedBy, Position, PositionTableId, VoxelType, VoxelTypeData } from "@tenet-contracts/src/codegen/Tables.sol";

contract BuildSystem is BuildEvent {
  function build(uint32 scale, bytes32 entity, VoxelCoord memory coord) public returns (uint32, bytes32) {
    // Require voxel to be owned by caller
    require(OwnedBy.get(scale, entity) == tx.origin, "voxel is not owned by player");
    VoxelTypeData memory voxelType = VoxelType.get(scale, entity);

    return super.build(voxelType.voxelTypeId, coord);
  }

  function buildVoxelType(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool buildChildren,
    bool buildParent
  ) public override returns (uint32, bytes32) {
    return super.buildVoxelType(voxelTypeId, coord, buildChildren, buildParent);
  }
}
