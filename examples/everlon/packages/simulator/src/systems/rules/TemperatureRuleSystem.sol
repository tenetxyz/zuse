// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { SimAction } from "@tenet-simulator/src/codegen/tables/SimAction.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Health, HealthData, HealthTableId } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina, StaminaTableId } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Temperature, TemperatureTableId } from "@tenet-simulator/src/codegen/tables/Temperature.sol";
import { Element, ElementTableId } from "@tenet-simulator/src/codegen/tables/Element.sol";

import { getEntityAtCoord, getVoxelCoordStrict, getEntityIdFromObjectEntityId, getVonNeumannNeighbourEntities } from "@tenet-base-world/src/Utils.sol";
import { VoxelCoord, SimTable, ElementType } from "@tenet-utils/src/Types.sol";
import { absoluteDifference, min } from "@tenet-utils/src/MathUtils.sol";
import { addUint256AndInt256, int256ToUint256, safeSubtract } from "@tenet-utils/src/TypeUtils.sol";

contract TemperatureRuleSystem is System {
  function applyTemperatureEffects(address worldAddress, bytes32 objectEntityId) public {
    if (!hasKey(TemperatureTableId, Temperature.encodeKeyTuple(worldAddress, objectEntityId))) {
      return;
    }

    // For each neighbour of a temperature object, apply temperature effects
    // ie update their health if not already updated
    uint256 entityTemperature = Temperature.get(worldAddress, objectEntityId);

    (bytes32[] memory neighbourEntities, ) = getVonNeumannNeighbourEntities(
      IStore(worldAddress),
      getEntityIdFromObjectEntityId(IStore(worldAddress), objectEntityId)
    );

    for (uint256 i = 0; i < neighbourEntities.length; i++) {
      if (uint256(neighbourEntities[i]) == 0) {
        continue;
      }

      bytes32 neighbourObjectEntityId = ObjectEntity.get(IStore(worldAddress), neighbourEntities[i]);

      if (!hasKey(HealthTableId, Health.encodeKeyTuple(worldAddress, neighbourObjectEntityId))) {
        continue;
      }

      HealthData memory healthData = Health.get(worldAddress, neighbourObjectEntityId);
      // Since a rule may be called multiple times during a tx, we only want to update
      // the health once as to not double count effects
      if (healthData.lastUpdateBlock == block.number) {
        continue;
      }

      // If the element type of the neighbour is fire, then we want to increase the health
      // Otherwise we want to decrease the health
      ElementType currentType = Element.get(worldAddress, neighbourObjectEntityId);
      uint256 energyCost = 0;
      uint256 newHealth = healthData.health;
      uint256 newTemperature = entityTemperature;
      uint256 difference = absoluteDifference(healthData.health, entityTemperature);
      // TODO: Find a cleaner way to do this calculation
      if (currentType == ElementType.Fire) {
        uint256 minSubtract = min(entityTemperature, difference);
        newTemperature = safeSubtract(entityTemperature, minSubtract);
        newHealth = healthData.health + minSubtract;
        energyCost = minSubtract;
      } else {
        uint256 minSubtract = min(healthData.health, min(entityTemperature, difference));
        newHealth = safeSubtract(healthData.health, minSubtract);
        newTemperature = safeSubtract(entityTemperature, minSubtract);
        energyCost = 2 * minSubtract;
      }

      Health.set(
        worldAddress,
        neighbourObjectEntityId,
        HealthData({ lastUpdateBlock: block.number, health: newHealth })
      );
      Temperature.set(worldAddress, objectEntityId, newTemperature);

      IWorld(_world()).fluxEnergy(false, worldAddress, objectEntityId, energyCost);
    }
  }
}
