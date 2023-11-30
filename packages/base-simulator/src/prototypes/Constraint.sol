// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getFirstCaller } from "@tenet-utils/src/Utils.sol";

abstract contract Constraint is System {
  // Note: This is added so that systems inside of the simulator world
  // can call constraints, and the constraint can get the original caller address (ie the world)
  function getCallerAddress() internal view returns (address) {
    address callerAddress = getFirstCaller();
    if (callerAddress == address(0)) {
      callerAddress = _msgSender();
    }
    return callerAddress;
  }

  // TODO: Figure out a way to include this in the abstract contract
  // function decodeAmounts(bytes memory fromAmount, bytes memory toAmount) internal virtual;

  // Note: these methods are kept internal, as we can't use namespaces
  // until MUD supports modules in namespaces, or KeysInTable is ported to core

  function transformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) internal virtual;

  function transfer(
    bytes32 senderObjectEntityId,
    VoxelCoord memory senderCoord,
    bytes32 receiverObjectEntityId,
    VoxelCoord memory receiverCoord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) internal virtual;
}
