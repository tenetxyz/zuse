// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { Action } from "@tenet-utils/src/Types.sol";

interface IObjectInteractionSystem {
  function decodeToBoolAndActionArray(bytes memory data) external pure returns (bool, Action[] memory);

  function decodeActionArray(bytes memory data) external pure returns (Action[] memory);

  function runInteractions(bytes32 centerEntityId) external;
}
