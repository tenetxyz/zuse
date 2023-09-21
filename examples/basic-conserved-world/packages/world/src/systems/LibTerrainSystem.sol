// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { AirVoxelID, GrassVoxelID, DirtVoxelID, BedrockVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { BodyPhysics, BodyPhysicsData } from "@tenet-world/src/codegen/Tables.sol";
import { getTerrainVoxelId } from "@tenet-base-ca/src/CallUtils.sol";

contract LibTerrainSystem is System {
  function getTerrainBodyPhysicsData(
    address caAddress,
    VoxelCoord memory coord
  ) public returns (bytes32, BodyPhysicsData memory) {
    BodyPhysicsData memory data;

    bytes32 voxelTypeId = getTerrainVoxelId(caAddress, coord);

    if (voxelTypeId == AirVoxelID) {
      data.mass = 0;
      data.energy = 0;
    } else if (voxelTypeId == BedrockVoxelID) {
      data.mass = 5;
      data.energy = 100;
    } else if (voxelTypeId == GrassVoxelID) {
      data.mass = 10;
      data.energy = 100;
    } else if (voxelTypeId == DirtVoxelID) {
      data.mass = 5;
      data.energy = 150;
    }
    data.velocity = abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 }));

    return (voxelTypeId, data);
  }
}
