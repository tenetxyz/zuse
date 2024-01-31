// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

import { Metadata, MetadataTableId } from "@tenet-world/src/codegen/tables/Metadata.sol";

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

  function postEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes memory eventData
  ) internal override {
    super.postEvent(actingObjectEntityId, objectTypeId, coord, eventEntityId, eventData);

    address callerAddress = _msgSender();
    // Clear all keys in Metadata if not called by World or Simulator
    // This would typically represent the end of a user call, vs the end of
    // an internal call
    if (callerAddress != _world() && callerAddress != getSimulatorAddress()) {
      bytes32[][] memory objectsRan = getKeysInTable(MetadataTableId);
      for (uint256 i = 0; i < objectsRan.length; i++) {
        Metadata.deleteRecord(objectsRan[i][0]);
      }
    }
  }

  function runObject(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes32 objectEntityId,
    bytes memory eventData
  ) internal override {
    // We don't want to run the object code if the caller is the simulator or the world
    // eg when the simulator/world is building terrain
    // TODO: Make this specific to terrain building not just any build
    address callerAddress = _msgSender();
    if (callerAddress != _world() && callerAddress != getSimulatorAddress()) {
      super.runObject(actingObjectEntityId, objectTypeId, coord, eventEntityId, objectEntityId, eventData);
    }
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
