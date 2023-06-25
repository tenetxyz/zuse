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

string constant STRING_ARR_DELIMITER = "|";

function stringArrToString(string[] memory stringArr) pure returns (string memory) {
  string memory resultStr = "";
  for (uint i = 0; i < stringArr.length; i++) {
    resultStr = string(abi.encodePacked(resultStr, stringArr[i]));
    if (i < stringArr.length - 1) {
      resultStr = string(abi.encodePacked(resultStr, STRING_ARR_DELIMITER));
    }
  }
  return resultStr;
}
