// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

import { SIMULATOR_ADDRESS, AirObjectID } from "@tenet-world/src/Constants.sol";
import { BuildSystem as BuildProtoSystem } from "@tenet-base-world/src/systems/BuildSystem.sol";
import { BuildEventData } from "@tenet-world/src/Types.sol";

contract BuildSystem is BuildProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function emptyObjectId() internal pure override returns (bytes32) {
    return AirObjectID;
  }

  function getInventoryId(bytes memory eventData) internal pure override returns (bytes32) {
    BuildEventData memory buildEventData = abi.decode(eventData, (BuildEventData));
    return buildEventData.inventoryId;
  }

  function build(
    bytes32 actingObjectEntityId,
    bytes32 buildObjectTypeId,
    VoxelCoord memory buildCoord,
    bytes32 inventoryId
  ) public override returns (bytes32) {
    BuildEventData memory buildEventData = BuildEventData({ inventoryId: inventoryId });
    return super.build(actingObjectEntityId, buildObjectTypeId, buildCoord, abi.encode(buildEventData));
  }

  function build(
    bytes32 actingObjectEntityId,
    bytes32 buildObjectTypeId,
    VoxelCoord memory buildCoord
  ) public override returns (bytes32) {
    return super.build(actingObjectEntityId, buildObjectTypeId, buildCoord);
  }

  function buildTerrain(bytes32 actingObjectEntityId, VoxelCoord memory buildCoord) public override returns (bytes32) {
    return super.buildTerrain(actingObjectEntityId, buildCoord);
  }
}
