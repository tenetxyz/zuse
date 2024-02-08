// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { Callers } from "@latticexyz/world/src/tables/Callers.sol";

function getFirstCaller() view returns (address) {
  address[] memory worldCallers = Callers.get();
  if (worldCallers.length > 0) {
    return worldCallers[0];
  }
  return address(0);
}

function getSecondCaller() view returns (address) {
  address[] memory worldCallers = Callers.get();
  if (worldCallers.length > 1) {
    return worldCallers[1];
  }
  return address(0);
}

function getCallerNamespace(address caller) view returns (bytes16) {
  require(uint256(SystemRegistry.get(caller)) != 0, "Caller is not a system"); // cannot be called by an EOA
  bytes32 resourceSelector = SystemRegistry.get(caller);
  bytes16 callerNamespace = ResourceSelector.getNamespace(resourceSelector);
  return callerNamespace;
}

function getCallerName(address caller) view returns (bytes16) {
  require(uint256(SystemRegistry.get(caller)) != 0, "Caller is not a system"); // cannot be called by an EOA
  bytes32 resourceSelector = SystemRegistry.get(caller);
  bytes16 callerName = ResourceSelector.getName(resourceSelector);
  return callerName;
}

function addressToEntityKey(address addr) pure returns (bytes32) {
  return bytes32(uint256(uint160(addr)));
}
