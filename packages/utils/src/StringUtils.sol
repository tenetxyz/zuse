// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

function int32ToString(int32 num) pure returns (string memory) {
  return Strings.toString(int256(num));
}

function bytes4ToString(bytes4 num) pure returns (string memory) {
  return Strings.toString(uint256(uint32(num)));
}
