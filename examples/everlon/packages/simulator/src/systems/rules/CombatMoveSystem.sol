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
import { Health, HealthTableId } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina, StaminaTableId } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { CombatMove, CombatMoveData, CombatMoveTableId } from "@tenet-simulator/src/codegen/tables/CombatMove.sol";
import { Element, ElementTableId } from "@tenet-simulator/src/codegen/tables/Element.sol";

import { getEntityAtCoord, getVoxelCoordStrict, getEntityIdFromObjectEntityId, getVonNeumannNeighbourEntities } from "@tenet-base-world/src/Utils.sol";
import { VoxelCoord, SimTable, ValueType, ElementType } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256, safeSubtract } from "@tenet-utils/src/TypeUtils.sol";

contract CombatMoveSystem is System {
  // Go through all combat moves that are not none, and apply them
  // This would happen when an object picks a combat move, and the target object
  // doesn't respond with a combat move
  function resolveCombatMoves() public {
    bytes32[][] memory objectEntitiesWithCombatMoves = getKeysInTable(CombatMoveTableId);
    for (uint256 i = 0; i < objectEntitiesWithCombatMoves.length; i++) {
      address worldAddress = address(uint160(uint256(objectEntitiesWithCombatMoves[i][0])));
      bytes32 objectEntityId = objectEntitiesWithCombatMoves[i][1];
      CombatMoveData memory combatMoveData = CombatMove.get(worldAddress, objectEntityId);
      bytes32 toObjectEntityId = combatMoveData.toObjectEntityId;
      if (toObjectEntityId != objectEntityId && combatMoveData.stamina > 0) {
        uint256 currentStamina = Stamina.get(worldAddress, objectEntityId);
        if (currentStamina > combatMoveData.stamina) {
          uint256 damage = IWorld(_world()).getHealthDiff(combatMoveData.stamina);
          // Note: we don't apply any type multipliers here because we only have one object move to work with
          uint256 lostHealth = damage;

          // Flux out energy proportional to the health lost and stamina used
          IWorld(_world()).fluxEnergy(false, worldAddress, objectEntityId, lostHealth + combatMoveData.stamina);

          Stamina.set(worldAddress, objectEntityId, safeSubtract(currentStamina, combatMoveData.stamina));
          Health.setHealth(
            worldAddress,
            toObjectEntityId,
            safeSubtract(Health.getHealth(worldAddress, toObjectEntityId), damage)
          );
        }
      }

      // We've now resolved the combat move, so delete it
      CombatMove.deleteRecord(worldAddress, objectEntityId);
    }
  }
}
