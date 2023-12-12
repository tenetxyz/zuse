// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

import { Metadata, MetadataTableId } from "@tenet-world/src/codegen/tables/Metadata.sol";

import { SIMULATOR_ADDRESS, AirObjectID } from "@tenet-world/src/Constants.sol";
import { ActivateSystem as ActivateProtoSystem } from "@tenet-base-world/src/systems/ActivateSystem.sol";

contract ActivateSystem is ActivateProtoSystem {
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

    // Clear all keys in Metadata
    bytes32[][] memory objectsRan = getKeysInTable(MetadataTableId);
    for (uint256 i = 0; i < objectsRan.length; i++) {
      Metadata.deleteRecord(objectsRan[i][0]);
    }
  }

  function activate(
    bytes32 actingObjectEntityId,
    bytes32 activateObjectTypeId,
    VoxelCoord memory activateCoord
  ) public override returns (bytes32) {
    return super.activate(actingObjectEntityId, activateObjectTypeId, activateCoord, new bytes(0));
  }
}
