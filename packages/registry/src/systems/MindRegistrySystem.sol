// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { MindRegistry, MindRegistryTableId, VoxelTypeRegistryTableId, VoxelTypeRegistry, WorldRegistry, WorldRegistryTableId, WorldRegistryData } from "@tenet-registry/src/codegen/Tables.sol";
import { Mind, CreationMetadata, DecisionRuleKey, CreationSpawns } from "@tenet-utils/src/Types.sol";

contract MindRegistrySystem is System {
  function registerMind(
    bytes32 voxelTypeId,
    string memory name,
    string memory description,
    DecisionRuleKey[] memory decisionRules
  ) public {
    registerMindForWorld(voxelTypeId, address(0), name, description, decisionRules);
  }

  function registerMindForWorld(
    bytes32 voxelTypeId,
    address worldAddress,
    string memory name,
    string memory description,
    DecisionRuleKey[] memory decisionRules
  ) public {
    require(
      hasKey(VoxelTypeRegistryTableId, VoxelTypeRegistry.encodeKeyTuple(voxelTypeId)),
      "Voxel type ID has not been registered"
    );
    if (worldAddress != address(0)) {
      require(
        hasKey(WorldRegistryTableId, WorldRegistry.encodeKeyTuple(worldAddress)),
        "World address hassources not been registered"
      );
    }
    // Set creator
    CreationSpawns[] memory spawns = new CreationSpawns[](0);
    bytes memory creationMetadata = abi.encode(CreationMetadata(tx.origin, name, description, spawns));
    Mind memory mind = Mind({ creationMetadata: creationMetadata, decisionRules: new DecisionRuleKey[](0) });

    Mind[] memory newMinds;
    if (hasKey(MindRegistryTableId, MindRegistry.encodeKeyTuple(voxelTypeId, worldAddress))) {
      bytes memory mindData = MindRegistry.get(voxelTypeId, worldAddress);
      Mind[] memory minds = abi.decode(mindData, (Mind[]));

      newMinds = new Mind[](minds.length + 1);
      for (uint256 i = 0; i < minds.length; i++) {
        require(minds[i].mindSelector != mind.mindSelector, "Mind already registered");
        newMinds[i] = minds[i];
      }
      newMinds[minds.length] = mind;
    } else {
      newMinds = new Mind[](1);
      newMinds[0] = mind;
    }

    MindRegistry.set(voxelTypeId, worldAddress, abi.encode(newMinds));
  }

  function areDecisionRulesTheSame(Mind memory existingMind, Mind memory newMind) private pure returns (bool) {
    if (existingMind.decisionRules.length != newMind.decisionRules.length) {
      return false;
    }
    for (uint256 i = 0; i < newMind.decisionRules.length; i++) {
      if (existingMind.decisionRules[i].decisionRuleId != newMind.decisionRules[i].decisionRuleId) {
        return false;
      }
    }
    return true;
  }
}
