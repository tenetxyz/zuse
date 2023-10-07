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
    bool entityExists = hasKey(
      StaminaTableId,
      Stamina.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
    );
    require(entityExists, "Stamina entity does not exist");
    uint256 currentStamina = Stamina.get(callerAddress, senderEntity.scale, senderEntity.entityId);
    require(currentStamina >= senderStamina, "Not enough stamina");

    ObjectType objectType = Object.get(callerAddress, senderEntity.scale, senderEntity.entityId);
    require(objectType != ObjectType.None, "Object type not set");

    uint256 newStamina = safeSubtract(currentStamina, senderStamina);
    // Flux out stamina
    IWorld(_world()).fluxEnergy(false, callerAddress, senderEntity, senderStamina);
    Stamina.set(callerAddress, senderEntity.scale, senderEntity.entityId, newStamina);

    int32 currentRound = Action.getRound(callerAddress, senderEntity.scale, senderEntity.entityId);
    Action.set(
      callerAddress,
      senderEntity.scale,
      senderEntity.entityId,
      receiverActionType,
      senderStamina,
      currentRound + 1,
      abi.encode(receiverEntity)
    );
    ActionData memory actionData = Action.get(callerAddress, senderEntity.scale, senderEntity.entityId);

    // Check if any neighbours are objects with also an action set
    (bytes32[] memory neighbourEntities, VoxelCoord[] memory neighbourCoords) = getNeighbourEntities(
      callerAddress,
      senderEntity
    );
    for (uint i = 0; i < neighbourEntities.length; i++) {
      if (uint256(neighbourEntities[i]) == 0) {
        // Note: we assume terrain gen can't have objects with actions
        continue;
      }
      VoxelEntity memory neighbourEntity = VoxelEntity({ scale: senderEntity.scale, entityId: neighbourEntities[i] });
      ActionData memory neighbourActionData = Action.get(
        callerAddress,
        neighbourEntity.scale,
        neighbourEntity.entityId
      );
      if (neighbourActionData.actionType == ObjectType.None) {
        continue;
      }
      ObjectType neighbourObjectType = Object.get(callerAddress, neighbourEntity.scale, neighbourEntity.entityId);
      if (neighbourObjectType == ObjectType.None) {
        continue;
      }

      updateHealth(
        callerAddress,
        senderEntity,
        objectType,
        actionData,
        neighbourEntity,
        neighbourObjectType,
        neighbourActionData
      );
      updateHealth(
        callerAddress,
        neighbourEntity,
        neighbourObjectType,
        neighbourActionData,
        senderEntity,
        objectType,
        actionData
      );
    }
  }

  function updateHealth(
    address callerAddress,
    VoxelEntity memory entity,
    ObjectType objectType,
    ActionData memory actionData,
    VoxelEntity memory neighbourEntity,
    ObjectType neighbourObjectType,
    ActionData memory neighbourActionData
  ) internal {
    require(
      actionData.actionType != ObjectType.None && neighbourActionData.actionType != ObjectType.None,
      "Action not set"
    );
    VoxelEntity memory neighbourActionEntity = abi.decode(neighbourActionData.actionEntity, (VoxelEntity));
    if (!isEntityEqual(neighbourActionEntity, entity)) {
      // This means, the neighbour has not done any action on us, so our health is not affected
      return;
    }

    uint256 damage = calculateDamage(
      objectType,
      actionData.stamina,
      neighbourObjectType,
      neighbourActionData.actionType
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
    if (newHealth == 0) {
      Action.set(
        callerAddress,
        entity.scale,
        entity.entityId,
        ObjectType.None,
        0,
        0,
        abi.encode(VoxelEntity({ scale: 0, entityId: bytes32(0) }))
      );
    }
    Health.set(callerAddress, entity.scale, entity.entityId, newHealth);
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
