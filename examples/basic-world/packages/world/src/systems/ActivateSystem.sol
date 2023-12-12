// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

import { SIMULATOR_ADDRESS, AirObjectID } from "@tenet-world/src/Constants.sol";
import { ActivateSystem as ActivateProtoSystem } from "@tenet-base-world/src/systems/ActivateSystem.sol";

contract ActivateSystem is ActivateProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function emptyObjectId() internal pure override returns (bytes32) {
    return AirObjectID;
  }

  function activate(
    bytes32 actingObjectEntityId,
    bytes32 activateObjectTypeId,
    VoxelCoord memory activateCoord
  ) public override returns (bytes32) {
    return super.activate(actingObjectEntityId, activateObjectTypeId, activateCoord, new bytes(0));
  }
}
