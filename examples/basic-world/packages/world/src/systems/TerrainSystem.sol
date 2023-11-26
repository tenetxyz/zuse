// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

import { SIMULATOR_ADDRESS, AirObjectID, DirtObjectID, GrassObjectID, BedrockObjectID } from "@tenet-world/src/Constants.sol";
import { TerrainSystem as TerrainProtoSystem } from "@tenet-base-world/src/systems/TerrainSystem.sol";

contract TerrainSystem is TerrainProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function emptyObjectId() internal pure override returns (bytes32) {
    return AirObjectID;
  }

  function getTerrainObjectTypeId(VoxelCoord memory coord) public view override returns (bytes32) {
    if (coord.y == 0) {
      return BedrockObjectID;
    } else if (coord.y > 0 && coord.y <= 9) {
      if (coord.y == 9) {
        return GrassObjectID;
      } else {
        return DirtObjectID;
      }
    }

    return AirObjectID;
  }

  function getTerrainObjectProperties(
    VoxelCoord memory coord,
    ObjectProperties memory requestedProperties
  ) public override returns (ObjectProperties memory) {
    ObjectProperties memory objectProperties;
    if (coord.y == 0) {
      objectProperties.mass = 50;
      objectProperties.energy = 500;
    } else if (coord.y > 0 && coord.y <= 9) {
      if (coord.y == 9) {
        objectProperties.mass = 5;
        objectProperties.energy = 50;
      } else {
        objectProperties.mass = 5;
        objectProperties.energy = 100;
      }
    } else {
      objectProperties.mass = 0;
      objectProperties.energy = 0;
    }

    return objectProperties;
  }
}
