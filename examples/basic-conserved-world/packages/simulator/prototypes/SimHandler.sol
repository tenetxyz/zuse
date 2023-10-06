// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getFirstCaller } from "@tenet-utils/src/Utils.sol";

abstract contract SimHandler is System {
  function getCallerAddress() internal view returns (address) {
    address callerAddress = getFirstCaller();
    if (callerAddress == address(0)) {
      callerAddress = _msgSender();
    }
    return callerAddress;
  }
}
