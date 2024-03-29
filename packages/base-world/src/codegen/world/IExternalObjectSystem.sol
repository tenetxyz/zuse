// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { ObjectProperties } from "@tenet-utils/src/Types.sol";

interface IExternalObjectSystem {
  function getObjectProperties(bytes32 objectEntityId) external view returns (ObjectProperties memory);
}
