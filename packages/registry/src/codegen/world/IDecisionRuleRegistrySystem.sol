// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

interface IDecisionRuleRegistrySystem {
  function registerDecisionRule(
    bytes32 srcObjectTypeId,
    bytes32 targetObjectTypeId,
    address decisionRuleAddress,
    bytes4 decisionRuleSelector,
    string memory name,
    string memory description
  ) external;
}
