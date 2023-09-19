// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { MindType } from "@tenet-base-ca/src/prototypes/MindType.sol";
import { VoxelType } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { VoxelCoord, CreationMetadata, CreationSpawns } from "@tenet-utils/src/Types.sol";
import { registerMindIntoRegistry } from "@tenet-registry/src/Utils.sol";
import { DecisionRuleRegistry } from "@tenet-registry/src/codegen/Tables/DecisionRuleRegistry.sol";
import { REGISTRY_ADDRESS, FighterVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { Mind, DecisionRule } from "@tenet-utils/src/Types.sol";
import { bytes4ToString } from "@tenet-utils/src/StringUtils.sol";

contract FighterMindSystem is MindType {
  function mindLogic(
    bytes32 voxelTypeId,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes4) {
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      // The first decision rule that this mind has that can handle a neighbour entity will be used
      bytes32 targetEntityId = neighbourEntityIds[i];
      if (targetEntityId == bytes32(0)) {
        continue;
      }

      address worldAddress = _world();
      //   bytes32 targetVoxelTypeId = VoxelType.getVoxelTypeId(worldAddress, 1, targetEntityId);
      //   bytes decisionRules = DecisionRuleRegistry.get(REGISTRY_ADDRESS, targetVoxelTypeId, worldAddress, address(0));
      // TODO: codegen the decisionRule selectors here
      //   bytes4[] memory decisionRuleSelectors = new bytes4[](1);
      for (uint8 j = 0; j < rules.length; j++) {
        DecisionRule memory rule = rules[j];

        bytes memory mindReturnData = safeCall(
          _world(),
          abi.encodeWithSelector(rule.decisionRuleSelector, voxelTypeId, targetEntityId),
          string(abi.encodePacked("call decision rule selector=", bytes4ToString(rule.decisionRuleSelector)))
        );
        bytes4 useInteractionSelector = abi.decode(mindReturnData, (bytes4));
        if (useinteractionSelector != bytes4(0)) {
          return useInteractionSelector;
        }
      }
    }
  }
}
