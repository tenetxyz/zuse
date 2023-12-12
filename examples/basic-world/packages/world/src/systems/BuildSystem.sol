// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

import { SIMULATOR_ADDRESS, AirObjectID } from "@tenet-world/src/Constants.sol";
import { BuildSystem as BuildProtoSystem } from "@tenet-base-world/src/systems/BuildSystem.sol";

contract BuildSystem is BuildProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function emptyObjectId() internal pure override returns (bytes32) {
    return AirObjectID;
  }

  function build(
    bytes32 actingObjectEntityId,
    bytes32 buildObjectTypeId,
    VoxelCoord memory buildCoord
  ) public override returns (bytes32) {
    return super.build(actingObjectEntityId, buildObjectTypeId, buildCoord, new bytes(0));
  }

  function buildTerrain(bytes32 actingObjectEntityId, VoxelCoord memory buildCoord) public override returns (bytes32) {
    return super.buildTerrain(actingObjectEntityId, buildCoord);
  }
}
