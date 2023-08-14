// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getFirstCaller } from "@tenet-utils/src/Utils.sol";

// Represents a voxel (or Minecraft block)
abstract contract Mind is System {
  function getCallerAddress() public view returns (address) {
    address callerAddress = getFirstCaller();
    if (callerAddress == address(0)) {
      callerAddress = _msgSender();
    }
    return callerAddress;
  }

  // Called once to register the mind
  function registerMind() public virtual;

  function mindLogic(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public virtual;
}
