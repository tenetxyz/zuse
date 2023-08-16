// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { InterfaceBody } from "@tenet-utils/src/Types.sol";

interface IClassifierRegistrySystem {
  function registerClassifier(
    bytes4 classifySelector,
    string memory name,
    string memory description,
    string memory classificationResultTableName,
    InterfaceBody[] memory selectorInterface
  ) external;
}
