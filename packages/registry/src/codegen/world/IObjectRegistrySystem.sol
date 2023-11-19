// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

interface IObjectRegistrySystem {
  function registerObjectType(
    bytes32 objectTypeId,
    address contractAddress,
    bytes4 enterWorldSelector,
    bytes4 exitWorldSelector,
    bytes4 eventHandlerSelector,
    bytes4 neighbourEventHandlerSelector,
    string memory name,
    string memory description
  ) external;
}
