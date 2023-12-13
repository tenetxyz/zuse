// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

import { SIMULATOR_ADDRESS, AirObjectID, DirtObjectID, GrassObjectID, BedrockObjectID, BuilderObjectID } from "@tenet-world/src/Constants.sol";
import { TerrainSystem as TerrainProtoSystem } from "@tenet-base-world/src/systems/TerrainSystem.sol";

contract TerrainSystem is TerrainProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function emptyObjectId() internal pure override returns (bytes32) {
    return AirObjectID;
  }

  function spawnInitialAgents() public {
    // TODO: Make this only callable once
    VoxelCoord memory initialAgentCoord1 = VoxelCoord(50, 10, 50);
    VoxelCoord memory initialAgentCoord2 = VoxelCoord(50, 10, 55);
    // Since the world is calling this, the acting entity can be 0
    IWorld(_world()).build(bytes32(0), BuilderObjectID, initialAgentCoord1);
    IWorld(_world()).build(bytes32(0), BuilderObjectID, initialAgentCoord2);
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
