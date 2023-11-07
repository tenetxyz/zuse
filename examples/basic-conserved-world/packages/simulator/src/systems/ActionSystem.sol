// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { Stamina, StaminaTableId, Action, ActionData, ActionTableId, SimSelectors, Object, ObjectTableId, Health, HealthTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, ObjectType, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { safeSubtract, int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity, getNeighbourEntities } from "@tenet-simulator/src/Utils.sol";
import { console } from "forge-std/console.sol";

contract ActionSystem is SimHandler {
  function registerActionSelectors() public {
    SimSelectors.set(
      SimTable.Stamina,
      SimTable.Action,
      IWorld(_world()).updateActionFromStamina.selector,
      ValueType.Int256,
      ValueType.ObjectType
    );
  }

  function postTxActionBehaviour() public {
    // go through all actions that are not none, and apply them

    // Clear all keys in Interactions
    bytes32[][] memory entitiesRan = getKeysInTable(ActionTableId);
    for (uint256 i = 0; i < entitiesRan.length; i++) {
      VoxelEntity memory actionEntity = VoxelEntity({
        scale: uint32(uint256(entitiesRan[i][1])),
        entityId: entitiesRan[i][2]
      });
      address callerAddress = address(uint160(uint256(entitiesRan[i][0])));
      ActionData memory actionData = Action.get(callerAddress, actionEntity.scale, actionEntity.entityId);
      if (actionData.actionType == ObjectType.None) {
        continue;
      }
      VoxelEntity memory toActOnEntity = abi.decode(actionData.actionEntity, (VoxelEntity));
      if (!isEntityEqual(actionEntity, toActOnEntity) && actionData.stamina > 0) {
        uint256 currentStamina = Stamina.get(callerAddress, actionEntity.scale, actionEntity.entityId);
        if (currentStamina > actionData.stamina) {
          console.log("applying single move");
          // Flux out energy proportional to the health lost and stamina used
          uint256 damage = actionData.stamina * 2;
          uint256 lostHealth = damage;
          IWorld(_world()).fluxEnergy(false, callerAddress, actionEntity, lostHealth + actionData.stamina);
          Stamina.set(
            callerAddress,
            actionEntity.scale,
            actionEntity.entityId,
            safeSubtract(currentStamina, actionData.stamina)
          );
          Health.setHealth(
            callerAddress,
            toActOnEntity.scale,
            toActOnEntity.entityId,
            safeSubtract(Health.getHealth(callerAddress, toActOnEntity.scale, toActOnEntity.entityId), damage)
          );
        }
      }

      // Set to none
      Action.set(
        callerAddress,
        actionEntity.scale,
        actionEntity.entityId,
        ActionData({
          actionType: ObjectType.None,
          stamina: 0,
          actionEntity: abi.encode(VoxelEntity({ scale: 0, entityId: bytes32(0) }))
        })
      );
    }
  }

  function updateActionFromStamina(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderStaminaDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    ObjectType receiverActionType
  ) public {
    address callerAddress = super.getCallerAddress();
    require(
      hasKey(StaminaTableId, Stamina.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)),
      "Stamina entity does not exist"
    );
    require(senderStaminaDelta < 0, "Cannot increase your own stamina");
    uint256 senderStamina = int256ToUint256(senderStaminaDelta);
    {
      ObjectType objectType = Object.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      require(objectType != ObjectType.None, "Object type not set");

      uint256 currentStamina = Stamina.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      require(currentStamina >= senderStamina, "Not enough stamina");
    }
    console.log("action set");
    console.logBytes32(senderEntity.entityId);
    Action.set(
      callerAddress,
      senderEntity.scale,
      senderEntity.entityId,
      ActionData({ actionType: receiverActionType, stamina: senderStamina, actionEntity: abi.encode(receiverEntity) })
    );

    // Check if any neighbours are objects with also an action set
    (bytes32[] memory neighbourEntities, ) = getNeighbourEntities(callerAddress, senderEntity);
    for (uint i = 0; i < neighbourEntities.length; i++) {
      if (uint256(neighbourEntities[i]) == 0) {
        // Note: we assume terrain gen can't have objects with actions
        continue;
      }
      VoxelEntity memory neighbourEntity = VoxelEntity({ scale: senderEntity.scale, entityId: neighbourEntities[i] });
      bool updatedSender = updateHealth(callerAddress, senderEntity, neighbourEntity);
      bool updatedNeighbour = updateHealth(callerAddress, neighbourEntity, senderEntity);
      require((!updatedSender && !updatedSender) || (updatedSender && updatedNeighbour), "Health mismatch");

      // set action type to None
      if (updatedSender) {
        Action.deleteRecord(callerAddress, senderEntity.scale, senderEntity.entityId);
      }
      if (updatedNeighbour) {
        Action.deleteRecord(callerAddress, neighbourEntity.scale, neighbourEntity.entityId);
      }
    }
  }

  function updateHealth(
    address callerAddress,
    VoxelEntity memory entity,
    VoxelEntity memory neighbourEntity
  ) internal returns (bool) {
    ObjectType objectType = Object.get(callerAddress, entity.scale, entity.entityId);
    ObjectType neighbourObjectType = Object.get(callerAddress, neighbourEntity.scale, neighbourEntity.entityId);
    if (objectType == ObjectType.None || neighbourObjectType == ObjectType.None) {
      return false;
    }
    ActionData memory actionData = Action.get(callerAddress, entity.scale, entity.entityId);
    ActionData memory neighbourActionData = Action.get(callerAddress, neighbourEntity.scale, neighbourEntity.entityId);
    if (actionData.actionType == ObjectType.None || neighbourActionData.actionType == ObjectType.None) {
      return false;
    }
    require(
      actionData.actionType != ObjectType.None && neighbourActionData.actionType != ObjectType.None,
      "Action not set"
    );
    console.log("fighting!");
    {
      VoxelEntity memory neighbourActionEntity = abi.decode(neighbourActionData.actionEntity, (VoxelEntity));
      if (!isEntityEqual(neighbourActionEntity, entity)) {
        // This means, the neighbour has not done any action on us, so our health is not affected
        console.log("neighbour has not done any action on us");
        return true;
      }
    }

    uint256 lostHealth;
    {
      uint256 damage = calculateDamage(
        neighbourObjectType,
        neighbourActionData.stamina,
        objectType,
        actionData.actionType
      );
      uint256 protection = 0;
      VoxelEntity memory actionEntity = abi.decode(actionData.actionEntity, (VoxelEntity));
      if (isEntityEqual(actionEntity, entity)) {
        protection = calculateProtection(
          objectType,
          actionData.stamina,
          neighbourObjectType,
          neighbourActionData.actionType
        );
      }
      lostHealth = safeSubtract(damage, protection);
    }
    console.log("lost health");
    console.logBytes32(entity.entityId);
    console.logUint(lostHealth);

    require(Stamina.get(callerAddress, entity.scale, entity.entityId) >= actionData.stamina, "Not enough stamina");

    // Flux out energy proportional to the health lost and stamina used
    IWorld(_world()).fluxEnergy(false, callerAddress, entity, lostHealth + actionData.stamina);
    {
      Stamina.set(
        callerAddress,
        entity.scale,
        entity.entityId,
        safeSubtract(Stamina.get(callerAddress, entity.scale, entity.entityId), actionData.stamina)
      );
      if (lostHealth > 0) {
        Health.setHealth(
          callerAddress,
          entity.scale,
          entity.entityId,
          safeSubtract(Health.getHealth(callerAddress, entity.scale, entity.entityId), lostHealth)
        );
      }
    }

    return true;
  }

  function calculateDamage(
    ObjectType senderObjectType,
    uint256 senderStamina,
    ObjectType receiverObjectType,
    ObjectType receiverActionType
  ) internal pure returns (uint256) {
    uint256 damage = senderStamina * 2;
    // TODO: Figure out how to calculate random factor
    uint256 randomFactor = 1;
    // We don't divide by 100 here so it doesn't round to zero
    uint256 actionTypeMultiplier = getTypeMultiplier(senderObjectType, receiverActionType);
    uint256 senderObjectTypeMultiplier = getTypeMultiplier(senderObjectType, receiverObjectType);
    return (damage * senderObjectTypeMultiplier * actionTypeMultiplier * randomFactor) / (100 * 100);
  }

  function calculateProtection(
    ObjectType senderObjectType,
    uint256 senderStamina,
    ObjectType receiverObjectType,
    ObjectType receiverActionType
  ) internal pure returns (uint256) {
    uint256 protection = senderStamina * 2;
    // TODO: Figure out how to calculate random factor
    uint256 randomFactor = 1;
    // We don't divide by 100 here so it doesn't round to zero
    uint256 actionTypeMultiplier = getTypeMultiplier(senderObjectType, receiverActionType);
    uint256 senderObjectTypeMultiplier = getTypeMultiplier(senderObjectType, receiverObjectType);
    return (protection * senderObjectTypeMultiplier * actionTypeMultiplier * randomFactor) / (100 * 100);
  }

  function getTypeMultiplier(ObjectType actionType, ObjectType neighbourObjectType) internal pure returns (uint256) {
    if (actionType == ObjectType.Fire) {
      if (neighbourObjectType == ObjectType.Fire) return 100;
      if (neighbourObjectType == ObjectType.Water) return 50;
      if (neighbourObjectType == ObjectType.Grass) return 200;
    } else if (actionType == ObjectType.Water) {
      if (neighbourObjectType == ObjectType.Fire) return 200;
      if (neighbourObjectType == ObjectType.Water) return 100;
      if (neighbourObjectType == ObjectType.Grass) return 50;
    } else if (actionType == ObjectType.Grass) {
      if (neighbourObjectType == ObjectType.Fire) return 50;
      if (neighbourObjectType == ObjectType.Water) return 200;
      if (neighbourObjectType == ObjectType.Grass) return 100;
    }
    revert("Invalid action types"); // Revert if none of the valid move types are matched
  }
}
