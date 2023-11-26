// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

import { SIMULATOR_ADDRESS, AirObjectID } from "@tenet-world/src/Constants.sol";
import { TerrainSystem as TerrainProtoSystem } from "@tenet-base-world/src/systems/TerrainSystem.sol";

contract TerrainSystem is TerrainProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function emptyObjectId() internal pure override returns (bytes32) {
    return AirObjectID;
  }

  function getTerrainObjectTypeId(VoxelCoord memory coord) public view override returns (bytes32) {
    return AirObjectID;
  }

  function getTerrainObjectProperties(
    ObjectProperties memory requestedProperties
  ) public override returns (ObjectProperties memory) {
    return requestedProperties;
  }
}
