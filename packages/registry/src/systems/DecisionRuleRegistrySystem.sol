// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/haskeys/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { DecisionRuleRegistry, DecisionRuleRegistryTableId, ObjectTypeRegistryTableId, ObjectTypeRegistry } from "../codegen/Tables.sol";
import { DecisionRule, CreationMetadata, CreationSpawns } from "@tenet-utils/src/Types.sol";

contract DecisionRuleRegistrySystem is System {
  function registerDecisionRule(
    bytes32 srcObjectTypeId,
    bytes32 targetObjectTypeId,
    address decisionRuleAddress,
    bytes4 decisionRuleSelector,
    string memory name,
    string memory description
  ) public {
    require(
      hasKey(ObjectTypeRegistryTableId, ObjectTypeRegistry.encodeKeyTuple(srcObjectTypeId)),
      "DecisionRuleRegstrySystem: srcObjectTypeId has not been registered"
    );
    require(
      hasKey(ObjectTypeRegistryTableId, ObjectTypeRegistry.encodeKeyTuple(targetObjectTypeId)),
      "DecisionRuleRegstrySystem: targetObjectTypeId has not been registered"
    );

    CreationSpawns[] memory spawns = new CreationSpawns[](0);
    DecisionRule memory decisionRule = DecisionRule({
      creationMetadata: abi.encode(CreationMetadata(tx.origin, name, description, spawns)),
      decisionRuleAddress: decisionRuleAddress,
      decisionRuleSelector: decisionRuleSelector
    });

    DecisionRule[] memory newDecisionRules;
    if (hasKey(DecisionRuleRegistryTableId, DecisionRuleRegistry.encodeKeyTuple(srcObjectTypeId, targetObjectTypeId))) {
      bytes memory decisionRuleData = DecisionRuleRegistry.get(srcObjectTypeId, targetObjectTypeId);
      DecisionRule[] memory decisionRules = abi.decode(decisionRuleData, (DecisionRule[]));

      newDecisionRules = new DecisionRule[](decisionRules.length + 1);
      for (uint256 i = 0; i < decisionRules.length; i++) {
        require(
          decisionRules[i].decisionRuleAddress != decisionRule.decisionRuleAddress ||
            decisionRules[i].decisionRuleSelector != decisionRule.decisionRuleSelector,
          "DecisionRuleRegstrySystem: DecisionRule already registered"
        );
        newDecisionRules[i] = decisionRules[i];
      }
      newDecisionRules[decisionRules.length] = decisionRule;
    } else {
      newDecisionRules = new DecisionRule[](1);
      newDecisionRules[0] = decisionRule;
    }

    DecisionRuleRegistry.set(srcObjectTypeId, targetObjectTypeId, abi.encode(newDecisionRules));
  }
}
