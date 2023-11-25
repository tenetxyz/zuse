// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { ActivateEvent } from "@tenet-base-world/src/prototypes/ActivateEvent.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

abstract contract ActivateSystem is ActivateEvent {
  function activate(
    bytes32 actingObjectEntityId,
    bytes32 activateObjectTypeId,
    VoxelCoord memory activateCoord
  ) public virtual returns (bytes32);
}
