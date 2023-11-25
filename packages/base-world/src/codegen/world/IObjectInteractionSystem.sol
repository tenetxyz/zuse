// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { EntityActionData } from "@tenet-utils/src/Types.sol";

interface IObjectInteractionSystem {
  function decodeToBoolAndBytes(bytes memory data) external pure returns (bool, bytes memory);

  function runInteractions(bytes32 centerEntityId) external returns (EntityActionData[] memory);
}