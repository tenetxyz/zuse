// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, Action } from "@tenet-utils/src/Types.sol";
import { getSecondCaller } from "@tenet-utils/src/Utils.sol";

// Represents a Mind
abstract contract MindType is System {
  // TODO: Remove this function once we know a better way to handle
  // address forwarding for agents
  function getCallerAddress() internal view returns (address) {
    // Note: the first caller is the EOA that called the world, so we skip it
    address callerAddress = getSecondCaller();
    if (callerAddress == address(0)) {
      callerAddress = _msgSender();
    }
    return callerAddress;
  }

  function eventHandlerSelector(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public virtual returns (address, bytes4);
}
