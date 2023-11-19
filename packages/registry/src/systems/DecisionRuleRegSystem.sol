// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { DecisionRuleRegistry, DecisionRuleRegistryTableId, ObjectTypeRegistryTableId, ObjectTypeRegistry } from "../codegen/Tables.sol";
import { DecisionRule, CreationMetadata, CreationSpawns } from "@tenet-utils/src/Types.sol";

// not called DecisionRuleRegstrySystem since the name is too long, which makes it cut off, which makes it have the same name as the table
contract DecisionRuleRegSystem is System {
  function registerDecisionRule(
    string memory name,
    string memory description,
    bytes32 srcVoxelTypeId,
    bytes32 targetVoxelTypeId,
    bytes4 decisionRuleSelector
  ) public {
    registerDecisionRuleForWorld(
      name,
      description,
      srcVoxelTypeId,
      targetVoxelTypeId,
      address(0),
      decisionRuleSelector
    );
  }

  function registerDecisionRuleForWorld(
    string memory name,
    string memory description,
    bytes32 srcVoxelTypeId,
    bytes32 targetVoxelTypeId,
    address worldAddress,
    bytes4 decisionRuleSelector
  ) public {
    require(
      hasKey(ObjectTypeRegistryTableId, ObjectTypeRegistry.encodeKeyTuple(srcVoxelTypeId)),
      "srcVoxelTypeId has not been registered"
    );
    require(
      hasKey(ObjectTypeRegistryTableId, ObjectTypeRegistry.encodeKeyTuple(targetVoxelTypeId)),
      "targetVoxelTypeId has not been registered"
    );

    CreationSpawns[] memory spawns = new CreationSpawns[](0);
    bytes32 decisionRuleId = keccak256(
      abi.encodePacked(srcVoxelTypeId, targetVoxelTypeId, worldAddress, decisionRuleSelector, _msgSender())
    );
    DecisionRule memory decisionRule = DecisionRule({
      decisionRuleId: decisionRuleId,
      creationMetadata: abi.encode(CreationMetadata(tx.origin, name, description, spawns)),
      decisionRuleSelector: decisionRuleSelector
    });

    DecisionRule[] memory newDecisionRules;
    if (hasKey(DecisionRuleRegistryTableId, DecisionRuleRegistry.encodeKeyTuple(srcVoxelTypeId, targetVoxelTypeId))) {
      bytes memory decisionRuleData = DecisionRuleRegistry.get(srcVoxelTypeId, targetVoxelTypeId);
      DecisionRule[] memory decisionRules = abi.decode(decisionRuleData, (DecisionRule[]));

      newDecisionRules = new DecisionRule[](decisionRules.length + 1);
      for (uint256 i = 0; i < decisionRules.length; i++) {
        require(
          decisionRules[i].decisionRuleSelector != decisionRule.decisionRuleSelector,
          "DecisionRule already registered"
        );
        newDecisionRules[i] = decisionRules[i];
      }
      newDecisionRules[decisionRules.length] = decisionRule;
    } else {
      newDecisionRules = new DecisionRule[](1);
      newDecisionRules[0] = decisionRule;
    }

    DecisionRuleRegistry.set(srcVoxelTypeId, targetVoxelTypeId, abi.encode(newDecisionRules));
  }
}
