// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Constraint } from "@tenet-base-simulator/src/prototypes/Constraint.sol";

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

contract StaminaCombatMoveConstraintSystem is Constraint {
  function registerStaminaCombatMoveSelector() public {
    SimAction.set(
      SimTable.Stamina,
      SimTable.CombatMove,
      IWorld(_world()).staminaCombatMoveTransformation.selector,
      IWorld(_world()).staminaCombatMoveTransfer.selector
    );
  }

  function decodeAmounts(bytes memory fromAmount, bytes memory toAmount) internal pure returns (int256, ElementType) {
    return (abi.decode(fromAmount, (int256)), abi.decode(toAmount, (ElementType)));
  }

  function staminaCombatMoveTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function staminaCombatMoveTransfer(
    bytes32 senderObjectEntityId,
    VoxelCoord memory senderCoord,
    bytes32 receiverObjectEntityId,
    VoxelCoord memory receiverCoord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transfer(senderObjectEntityId, senderCoord, receiverObjectEntityId, receiverCoord, fromAmount, toAmount);
  }

  // Represents a defense combat move
  function transformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) internal override {
    address worldAddress = super.getCallerAddress();
    (int256 senderStaminaDelta, ElementType receiverActionType) = decodeAmounts(fromAmount, toAmount);
    require(senderStaminaDelta < 0, "StaminaCombatMoveConstraintSystem: Cannot increase your own stamina");
    uint256 senderStamina = int256ToUint256(senderStaminaDelta);
    setCombatMove(worldAddress, objectEntityId, objectEntityId, senderStamina, receiverActionType);
    runCombat(worldAddress, objectEntityId);
  }

  // Represents an offense combat move
  function transfer(
    bytes32 senderObjectEntityId,
    VoxelCoord memory senderCoord,
    bytes32 receiverObjectEntityId,
    VoxelCoord memory receiverCoord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) internal override {
    address worldAddress = super.getCallerAddress();
    (int256 senderStaminaDelta, ElementType receiverActionType) = decodeAmounts(fromAmount, toAmount);
    require(senderStaminaDelta < 0, "StaminaCombatMoveConstraintSystem: Cannot increase your own stamina");
    uint256 senderStamina = int256ToUint256(senderStaminaDelta);
    setCombatMove(worldAddress, senderObjectEntityId, receiverObjectEntityId, senderStamina, receiverActionType);
    runCombat(worldAddress, senderObjectEntityId);
  }

  function setCombatMove(
    address worldAddress,
    bytes32 senderObjectEntityId,
    bytes32 receiverObjectEntityId,
    uint256 senderStamina,
    ElementType moveElementType
  ) internal {
    require(
      hasKey(StaminaTableId, Stamina.encodeKeyTuple(worldAddress, senderObjectEntityId)),
      "StaminaCombatMoveConstraintSystem: Stamina not initialized"
    );
    require(
      Element.get(worldAddress, senderObjectEntityId) != ElementType.None,
      "StaminaCombatMoveConstraintSystem: Element not initialized"
    );
    uint256 currentStamina = Stamina.get(worldAddress, senderObjectEntityId);
    require(currentStamina >= senderStamina, "StaminaCombatMoveConstraintSystem: Not enough stamina");

    CombatMove.set(
      worldAddress,
      senderObjectEntityId,
      CombatMoveData({ moveType: moveElementType, stamina: senderStamina, toObjectEntityId: receiverObjectEntityId })
    );
  }

  function runCombat(address worldAddress, bytes32 objectEntityId) internal {
    // Check if any neighbours are objects with also an action set
    (bytes32[] memory neighbourEntities, ) = getVonNeumannNeighbourEntities(
      IStore(worldAddress),
      getEntityIdFromObjectEntityId(IStore(worldAddress), objectEntityId)
    );
    for (uint i = 0; i < neighbourEntities.length; i++) {
      if (uint256(neighbourEntities[i]) == 0) {
        // Note: we assume terrain gen can't have objects with combat moves
        continue;
      }
      bytes32 neighbourObjectEntityId = ObjectEntity.get(IStore(worldAddress), neighbourEntities[i]);
      // TODO: Find a cleaner way to do this
      bool updatedObject = updateHealthFromCombat(worldAddress, objectEntityId, neighbourObjectEntityId);
      bool updatedNeighbour = updateHealthFromCombat(worldAddress, neighbourObjectEntityId, objectEntityId);
      require(
        (!updatedObject && !updatedNeighbour) || (updatedObject && updatedNeighbour),
        "StaminaCombatMoveConstraintSystem: updateHealthFromCombat result mismatch"
      );

      // delete combat move, as we've just processed it
      if (updatedObject) {
        CombatMove.deleteRecord(worldAddress, objectEntityId);
      }
      if (updatedNeighbour) {
        CombatMove.deleteRecord(worldAddress, neighbourObjectEntityId);
      }
    }
  }

  function updateHealthFromCombat(
    address worldAddress,
    bytes32 objectEntityId,
    bytes32 neighbourObjectEntityId
  ) internal returns (bool) {
    ElementType elementType = Element.get(worldAddress, objectEntityId);
    ElementType neighbourElementType = Element.get(worldAddress, neighbourObjectEntityId);
    if (elementType == ElementType.None || neighbourElementType == ElementType.None) {
      return false;
    }
    CombatMoveData memory combatMoveData = CombatMove.get(worldAddress, objectEntityId);
    CombatMoveData memory neighbourCombatMoveData = CombatMove.get(worldAddress, neighbourObjectEntityId);
    if (combatMoveData.moveType == ElementType.None || neighbourCombatMoveData.moveType == ElementType.None) {
      return false;
    }
    if (neighbourCombatMoveData.toObjectEntityId != objectEntityId) {
      // This means, the neighbour has not done any action on us, so our health is not affected
      return true;
    }

    uint256 lostHealth;
    {
      uint256 damage = calculateDamage(
        neighbourElementType,
        neighbourCombatMoveData.stamina,
        elementType,
        neighbourCombatMoveData.moveType
      );
      uint256 protection = 0;
      if (combatMoveData.toObjectEntityId == objectEntityId) {
        protection = calculateProtection(
          elementType,
          combatMoveData.stamina,
          neighbourElementType,
          combatMoveData.moveType
        );
      }
      lostHealth = safeSubtract(damage, protection);
    }
    require(
      Stamina.get(worldAddress, objectEntityId) >= combatMoveData.stamina,
      "StaminaCombatMoveConstraintSystem: Not enough stamina"
    );

    // Flux out energy proportional to the health lost and stamina used
    IWorld(_world()).fluxEnergy(false, worldAddress, objectEntityId, lostHealth + combatMoveData.stamina);

    Stamina.set(
      worldAddress,
      objectEntityId,
      safeSubtract(Stamina.get(worldAddress, objectEntityId), combatMoveData.stamina)
    );
    if (lostHealth > 0) {
      Health.setHealth(
        worldAddress,
        objectEntityId,
        safeSubtract(Health.getHealth(worldAddress, objectEntityId), lostHealth)
      );
    }

    return true;
  }

  function calculateDamage(
    ElementType senderObjectElementType,
    uint256 senderStamina,
    ElementType receiverObjectElementType,
    ElementType receiverCombatMoveType
  ) internal view returns (uint256) {
    uint256 damage = getHealthDiff(senderStamina);
    // TODO: Figure out how to calculate random factor
    uint256 randomFactor = 1;
    // We don't divide by 100 here so it doesn't round to zero
    uint256 objectElementTypeMultiplier = getElementTypeMultiplier(senderObjectElementType, receiverObjectElementType);
    uint256 combatMoveTypeMultiplier = getElementTypeMultiplier(senderObjectElementType, receiverCombatMoveType);
    return (damage * objectElementTypeMultiplier * combatMoveTypeMultiplier * randomFactor) / (100 * 100);
  }

  function calculateProtection(
    ElementType senderObjectElementType,
    uint256 senderStamina,
    ElementType receiverObjectElementType,
    ElementType receiverCombatMoveType
  ) internal view returns (uint256) {
    uint256 protection = getHealthDiff(senderStamina);
    // TODO: Figure out how to calculate random factor
    uint256 randomFactor = 1;
    // We don't divide by 100 here so it doesn't round to zero
    uint256 objectElementTypeMultiplier = getElementTypeMultiplier(senderObjectElementType, receiverObjectElementType);
    uint256 combatMoveTypeMultiplier = getElementTypeMultiplier(senderObjectElementType, receiverCombatMoveType);
    return (protection * objectElementTypeMultiplier * combatMoveTypeMultiplier * randomFactor) / (100 * 100);
  }

  function getElementTypeMultiplier(ElementType type1, ElementType type2) internal pure returns (uint256) {
    if (type1 == ElementType.Fire) {
      if (type2 == ElementType.Fire) return 100;
      if (type2 == ElementType.Water) return 50;
      if (type2 == ElementType.Grass) return 200;
    } else if (type1 == ElementType.Water) {
      if (type2 == ElementType.Fire) return 200;
      if (type2 == ElementType.Water) return 100;
      if (type2 == ElementType.Grass) return 50;
    } else if (type1 == ElementType.Grass) {
      if (type2 == ElementType.Fire) return 50;
      if (type2 == ElementType.Water) return 200;
      if (type2 == ElementType.Grass) return 100;
    }
    revert("StaminaCombatMoveConstraintSystem: Invalid element type");
  }

  function getHealthDiff(uint256 staminaSpent) public pure returns (uint256) {
    uint256 healthDiff = (staminaSpent * 65) / 10000;
    if (healthDiff > 25) {
      // apply a larger health diff
      healthDiff = (staminaSpent * 55) / 10000;
      if (healthDiff > 50) {
        healthDiff = (staminaSpent * 45) / 10000;
      }
    }
    return healthDiff;
  }
}
