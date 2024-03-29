// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Health, HealthTableId } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Metadata, MetadataTableId } from "@tenet-simulator/src/codegen/tables/Metadata.sol";

import { VoxelCoord, SimTable, ElementType } from "@tenet-utils/src/Types.sol";
import { NUM_MAX_BLOCKS_TO_WAIT_IF_NO_HEALTH, NUM_MIN_HEALTH_FOR_NO_WAIT } from "@tenet-simulator/src/Constants.sol";

contract HealthRuleSystem is System {
  function checkActingObjectHealth(address worldAddress, bytes32 actingObjectEntityId) public {
    if (!hasKey(HealthTableId, Health.encodeKeyTuple(worldAddress, actingObjectEntityId))) {
      return;
    }
    uint256 health = Health.getHealth(worldAddress, actingObjectEntityId);
    uint256 blocksToWait;
    if (health == 0) {
      blocksToWait = NUM_MAX_BLOCKS_TO_WAIT_IF_NO_HEALTH;
    } else {
      blocksToWait = NUM_MIN_HEALTH_FOR_NO_WAIT / health;
    }
    // Check if enough time has passed
    uint256 lastBlock = Metadata.get(worldAddress, actingObjectEntityId);
    if (lastBlock == 0 || block.number - lastBlock >= blocksToWait) {
      if (lastBlock != block.number) {
        Metadata.set(worldAddress, actingObjectEntityId, block.number);
      }
    } else {
      revert("HealthRuleSystem: Not enough time has passed to act since last event based on current health");
    }
  }
}
