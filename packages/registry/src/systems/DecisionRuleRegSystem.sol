// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { DecisionRuleRegistry, DecisionRuleRegistryTableId, VoxelTypeRegistryTableId, VoxelTypeRegistry, WorldRegistry, WorldRegistryTableId, WorldRegistryData } from "../codegen/Tables.sol";
import { DecisionRule } from "@tenet-utils/src/Types.sol";

// not called DecisionRuleRegstrySystem since the name is too long, which makes it cut off, which makes it have the same name as the table
contract DecisionRuleRegSystem is System {
  function registerDecisionRule(
    bytes32 srcVoxelTypeId,
    bytes32 targetVoxelTypeId,
    DecisionRule memory decisionRule
  ) public {
    registerDecisionRuleForWorld(srcVoxelTypeId, targetVoxelTypeId, address(0), decisionRule);
  }

  function registerDecisionRuleForWorld(
    bytes32 srcVoxelTypeId,
    bytes32 targetVoxelTypeId,
    address worldAddress,
    DecisionRule memory decisionRule
  ) public {
    require(
      hasKey(VoxelTypeRegistryTableId, VoxelTypeRegistry.encodeKeyTuple(srcVoxelTypeId)),
      "srcVoxelTypeId has not been registered"
    );
    require(
      hasKey(VoxelTypeRegistryTableId, VoxelTypeRegistry.encodeKeyTuple(targetVoxelTypeId)),
      "targetVoxelTypeId has not been registered"
    );
    if (worldAddress != address(0)) {
      require(
        hasKey(WorldRegistryTableId, WorldRegistry.encodeKeyTuple(worldAddress)),
        "World address has not been registered"
      );
    }

    decisionRule.creator = tx.origin;
    decisionRule.decisionRuleId = keccak256(
      abi.encodePacked(
        srcVoxelTypeId,
        targetVoxelTypeId,
        worldAddress,
        decisionRule.decisionRuleSelector,
        decisionRule.creator
      )
    );

    DecisionRule[] memory newDecisionRules;
    if (
      hasKey(
        DecisionRuleRegistryTableId,
        DecisionRuleRegistry.encodeKeyTuple(srcVoxelTypeId, targetVoxelTypeId, worldAddress)
      )
    ) {
      bytes memory decisionRuleData = DecisionRuleRegistry.get(srcVoxelTypeId, targetVoxelTypeId, worldAddress);
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

    DecisionRuleRegistry.set(srcVoxelTypeId, targetVoxelTypeId, worldAddress, abi.encode(newDecisionRules));
  }
}
