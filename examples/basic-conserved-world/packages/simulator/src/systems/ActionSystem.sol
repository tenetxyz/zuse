// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { Stamina, StaminaTableId, Action, ActionData, SimSelectors, Object, ObjectTableId, Health, HealthTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, ObjectType, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord, safeSubtract } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity, getNeighbourEntities } from "@tenet-simulator/src/Utils.sol";
import { console } from "forge-std/console.sol";

contract ActionSystem is SimHandler {
  function registerActionSelectors() public {
    SimSelectors.set(
      SimTable.Stamina,
      SimTable.Action,
      IWorld(_world()).setActionFromStamina.selector,
      ValueType.Uint256,
      ValueType.ObjectType
    );
  }

  function setActionFromStamina(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    uint256 senderStamina,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    ObjectType receiverActionType
  ) public {
    address callerAddress = super.getCallerAddress();
    require(
      hasKey(StaminaTableId, Stamina.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)),
      "Stamina entity does not exist"
    );
    {
      uint256 currentStamina = Stamina.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      require(currentStamina >= senderStamina, "Not enough stamina");

      ObjectType objectType = Object.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      require(objectType != ObjectType.None, "Object type not set");

      // Flux out energy proportional to the stamina used
      IWorld(_world()).fluxEnergy(false, callerAddress, senderEntity, senderStamina);
      Stamina.set(
        callerAddress,
        senderEntity.scale,
        senderEntity.entityId,
        safeSubtract(currentStamina, senderStamina)
      );
    }
    // int32 currentRound = Action.getRound(callerAddress, senderEntity.scale, senderEntity.entityId);
    Action.set(
      callerAddress,
      senderEntity.scale,
      senderEntity.entityId,
      ActionData({
        actionType: receiverActionType,
        stamina: senderStamina,
        round: 0,
        actionEntity: abi.encode(receiverEntity)
      })
    );

    // Check if any neighbours are objects with also an action set
    (bytes32[] memory neighbourEntities, ) = getNeighbourEntities(callerAddress, senderEntity);
    for (uint i = 0; i < neighbourEntities.length; i++) {
      if (uint256(neighbourEntities[i]) == 0) {
        // Note: we assume terrain gen can't have objects with actions
        continue;
      }
      VoxelEntity memory neighbourEntity = VoxelEntity({ scale: senderEntity.scale, entityId: neighbourEntities[i] });
      updateHealth(callerAddress, senderEntity, neighbourEntity);
      updateHealth(callerAddress, neighbourEntity, senderEntity);

      // set action type to None
      Action.set(
        callerAddress,
        senderEntity.scale,
        senderEntity.entityId,
        ObjectType.None,
        0,
        0,
        abi.encode(VoxelEntity({ scale: 0, entityId: bytes32(0) }))
      );
      Action.set(
        callerAddress,
        neighbourEntity.scale,
        neighbourEntity.entityId,
        ObjectType.None,
        0,
        0,
        abi.encode(VoxelEntity({ scale: 0, entityId: bytes32(0) }))
      );
    }

    // if (newStamina == 0) {}
  }

  function updateHealth(address callerAddress, VoxelEntity memory entity, VoxelEntity memory neighbourEntity) internal {
    ObjectType objectType = Object.get(callerAddress, entity.scale, entity.entityId);
    ObjectType neighbourObjectType = Object.get(callerAddress, neighbourEntity.scale, neighbourEntity.entityId);
    if (objectType == ObjectType.None || neighbourObjectType == ObjectType.None) {
      return;
    }
    ActionData memory actionData = Action.get(callerAddress, entity.scale, entity.entityId);
    ActionData memory neighbourActionData = Action.get(callerAddress, neighbourEntity.scale, neighbourEntity.entityId);
    if (actionData.actionType == ObjectType.None || neighbourActionData.actionType == ObjectType.None) {
      return;
    }
    require(
      actionData.actionType != ObjectType.None && neighbourActionData.actionType != ObjectType.None,
      "Action not set"
    );
    // require(actionData.round == neighbourActionData.round, "Rounds not equal");
    VoxelEntity memory neighbourActionEntity = abi.decode(neighbourActionData.actionEntity, (VoxelEntity));
    if (!isEntityEqual(neighbourActionEntity, entity)) {
      // This means, the neighbour has not done any action on us, so our health is not affected
      return;
    }

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
    uint256 lostHealth = safeSubtract(damage, protection);
    if (lostHealth == 0) {
      return;
    }
    uint256 newHealth = safeSubtract(Health.get(callerAddress, entity.scale, entity.entityId), lostHealth);
    // Flux out energy proportional to the health lost
    IWorld(_world()).fluxEnergy(false, callerAddress, entity, lostHealth);
    Health.set(callerAddress, entity.scale, entity.entityId, newHealth);
    // if (newHealth == 0) {}
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
    uint256 actionTypeMultiplier = getTypeMultiplier(senderObjectType, receiverActionType) / 100;
    uint256 senderObjectTypeMultiplier = getTypeMultiplier(senderObjectType, receiverObjectType) / 100;
    return damage * senderObjectTypeMultiplier * actionTypeMultiplier * randomFactor;
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
    uint256 actionTypeMultiplier = getTypeMultiplier(senderObjectType, receiverActionType) / 100;
    uint256 senderObjectTypeMultiplier = getTypeMultiplier(senderObjectType, receiverObjectType) / 100;
    return protection * senderObjectTypeMultiplier * actionTypeMultiplier * randomFactor;
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
