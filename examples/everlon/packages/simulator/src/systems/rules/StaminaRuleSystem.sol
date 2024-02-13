// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/haskeys/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Health, HealthData, HealthTableId } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina, StaminaData, StaminaTableId } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Metadata, MetadataTableId } from "@tenet-simulator/src/codegen/tables/Metadata.sol";

import { VoxelCoord, SimTable, ElementType } from "@tenet-utils/src/Types.sol";
import { MAX_AGENT_STAMINA, NUM_BLOCKS_BEFORE_INCREASE_STAMINA, STAMINA_INCREASE_RATE } from "@tenet-simulator/src/Constants.sol";

contract StaminaRuleSystem is System {
  function applyStaminaIncrease(address worldAddress, bytes32 objectEntityId) public {
    if (!hasKey(StaminaTableId, Stamina.encodeKeyTuple(worldAddress, objectEntityId))) {
      return;
    }

    StaminaData memory staminaData = Stamina.get(worldAddress, objectEntityId);
    if (staminaData.stamina >= MAX_AGENT_STAMINA) {
      Stamina.setLastUpdateBlock(worldAddress, objectEntityId, block.number);
      return;
    }
    // Calculate how many blocks have passed since last update
    uint256 blocksSinceLastUpdate = block.number - staminaData.lastUpdateBlock;
    if (blocksSinceLastUpdate <= NUM_BLOCKS_BEFORE_INCREASE_STAMINA) {
      return;
    }

    // Calculate the new stamina
    uint256 numAddStamina = (blocksSinceLastUpdate / NUM_BLOCKS_BEFORE_INCREASE_STAMINA) * STAMINA_INCREASE_RATE;
    uint256 newStamina = staminaData.stamina + numAddStamina;
    if (newStamina > MAX_AGENT_STAMINA) {
      newStamina = MAX_AGENT_STAMINA;
    }

    Stamina.set(worldAddress, objectEntityId, StaminaData({ stamina: newStamina, lastUpdateBlock: block.number }));
  }
}
