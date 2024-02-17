// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

import { ObjectMetadata, ObjectMetadataTableId } from "@tenet-world/src/codegen/tables/ObjectMetadata.sol";

import { SIMULATOR_ADDRESS, AirObjectID } from "@tenet-world/src/Constants.sol";
import { MoveSystem as MoveProtoSystem } from "@tenet-base-world/src/systems/MoveSystem.sol";
import { MoveEventData } from "@tenet-world/src/Types.sol";
import { getEntityAtCoord } from "@tenet-base-world/src/Utils.sol";

contract MoveSystem is MoveProtoSystem {
  function getOldCoord(bytes memory eventData) internal pure override returns (VoxelCoord memory) {
    MoveEventData memory moveEventData = abi.decode(eventData, (MoveEventData));
    return moveEventData.oldCoord;
  }

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
      bytes32[][] memory objectsRan = getKeysInTable(ObjectMetadataTableId);
      for (uint256 i = 0; i < objectsRan.length; i++) {
        ObjectMetadata.deleteRecord(objectsRan[i][0]);
      }
    }
  }

  function move(
    bytes32 actingObjectEntityId,
    bytes32 moveObjectTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord
  ) public override returns (bytes32, bytes32) {
    MoveEventData memory moveEventData = MoveEventData({ oldCoord: oldCoord });
    return super.move(actingObjectEntityId, moveObjectTypeId, newCoord, abi.encode(moveEventData));
  }

  function move(
    bytes32 actingObjectEntityId,
    bytes32 moveObjectTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord[] memory newCoords
  ) public returns (bytes32, bytes32) {
    bytes32 oldEntityId = getEntityAtCoord(IStore(_world()), oldCoord);
    bytes32 newEntityId;
    VoxelCoord memory workingOldCoord = oldCoord;
    for (uint256 i = 0; i < newCoords.length; i++) {
      MoveEventData memory moveEventData = MoveEventData({ oldCoord: workingOldCoord });
      (, newEntityId) = super.move(actingObjectEntityId, moveObjectTypeId, newCoords[i], abi.encode(moveEventData));
      workingOldCoord = newCoords[i];
    }
    return (oldEntityId, newEntityId);
  }
}
