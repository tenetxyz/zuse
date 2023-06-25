// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";
import { ResourceSelector} from "@latticexyz/world/src/ResourceSelector.sol";

function getCallerNamespace(address caller) view returns (bytes16) {
  require(uint256(SystemRegistry.get(caller)) != 0, "Caller is not a system"); // cannot be called by an EOA
  bytes32 resourceSelector = SystemRegistry.get(caller);
  bytes16 callerNamespace = ResourceSelector.getNamespace(resourceSelector);
  return callerNamespace;
}

function materialsArrToString(string[] memory materials) pure returns (string memory) {
  string memory materialsStr = "";
  for (uint i = 0; i < materials.length; i++) {
    materialsStr = string(abi.encodePacked(materialsStr, materials[i]));
    if (i < materials.length - 1) {
      materialsStr = string(abi.encodePacked(materialsStr, "|"));
    }
  }
  return materialsStr;
}