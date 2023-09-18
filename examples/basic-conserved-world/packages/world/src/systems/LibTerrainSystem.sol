// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { AirVoxelID, GrassVoxelID, DirtVoxelID, BedrockVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { BodyPhysics, BodyPhysicsData } from "@tenet-world/src/codegen/Tables.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract LibTerrainSystem is System {
  function getTerrainBodyPhysicsData(
    address caAddress,
    VoxelCoord memory coord
  ) public returns (BodyPhysicsData memory) {
    BodyPhysicsData memory data;

    bytes memory returnData = safeCall(
      caAddress,
      abi.encodeWithSignature("ca_LibTerrainSystem_getTerrainVoxel((int32,int32,int32))", coord),
      string(abi.encode("ca_LibTerrainSystem_getTerrainVoxel ", coord))
    );
    bytes32 voxelTypeId = abi.decode(returnData, (bytes32));

    if (voxelTypeId == AirVoxelID) {
      return data;
    }

    if (voxelTypeId == BedrockVoxelID) {
      data.mass = 100;
      data.energy = 1;
      return data;
    }

    if (voxelTypeId == GrassVoxelID) {
      data.mass = 10;
      data.energy = 100;
      return data;
    }

    if (voxelTypeId == DirtVoxelID) {
      data.mass = 5;
      data.energy = 150;
      return data;
    }

    return data;
  }
}
