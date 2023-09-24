// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { AirVoxelID, GrassVoxelID, DirtVoxelID, BedrockVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { BodyPhysics, BodyPhysicsData, VoxelTypeProperties } from "@tenet-world/src/codegen/Tables.sol";
import { getTerrainVoxelId } from "@tenet-base-ca/src/CallUtils.sol";

contract LibTerrainSystem is System {
  function getTerrainBodyPhysicsData(
    address caAddress,
    VoxelCoord memory coord
  ) public returns (bytes32, BodyPhysicsData memory) {
    BodyPhysicsData memory data;

    bytes32 voxelTypeId = getTerrainVoxelId(caAddress, coord);

    data.mass = VoxelTypeProperties.get(voxelTypeId);
    if (voxelTypeId == AirVoxelID) {
      data.energy = 0;
    } else if (voxelTypeId == BedrockVoxelID) {
      data.energy = 1;
    } else if (voxelTypeId == GrassVoxelID) {
      data.energy = 100;
    } else if (voxelTypeId == DirtVoxelID) {
      data.energy = 150;
    }
    data.velocity = abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 }));
    data.lastUpdateBlock = block.number;

    return (voxelTypeId, data);
  }
}
