// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { CA } from "@tenet-base-ca/src/prototypes/CA.sol";
import { CAPosition, CAPositionData } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { EMPTY_ID } from "./LibTerrainSystem.sol";

contract CASystem is CA {
  function emptyVoxelId() internal pure override returns (bytes32) {
    return Level2AirVoxelID;
  }

  function terrainGen(
    address callerAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes32 entity
  ) internal override {
    // If there is no entity at this position, try mining the terrain voxel at this position
    bytes32 terrainVoxelTypeId = IWorld(_world()).getTerrainVoxel(coord);
    require(terrainVoxelTypeId != EMPTY_ID && terrainVoxelTypeId == voxelTypeId, "invalid terrain voxel type");
    CAPosition.set(callerAddress, entity, CAPositionData({ x: coord.x, y: coord.y, z: coord.z }));
  }
}
