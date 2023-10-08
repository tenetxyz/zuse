// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { SimSelectors, Health, HealthTableId, Stamina, StaminaTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity, createTerrainEntity } from "@tenet-simulator/src/Utils.sol";
import { console } from "forge-std/console.sol";

contract StaminaSystem is SimHandler {
  function registerStaminaSelectors() public {
    SimSelectors.set(
      SimTable.Energy,
      SimTable.Stamina,
      IWorld(_world()).updateStaminaFromEnergy.selector,
      ValueType.Int256,
      ValueType.Int256
    );
    SimSelectors.set(
      SimTable.Stamina,
      SimTable.Stamina,
      IWorld(_world()).updateStaminaFromStamina.selector,
      ValueType.Int256,
      ValueType.Int256
    );
  }

  function updateStaminaFromEnergy(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderEnergyDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    int256 receiverStaminaDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = hasKey(
      EnergyTableId,
      Energy.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
    );
    require(entityExists, "Sender entity does not exist");
    if (isEntityEqual(senderEntity, receiverEntity)) {
      revert("You can't convert your own energy to stamina");
    } else {
      require(receiverStaminaDelta > 0, "Cannot decrease others stamina");
      require(senderEnergyDelta < 0, "Cannot increase your own energy");
      uint256 senderEnergy = int256ToUint256(senderEnergyDelta);
      uint256 receiverStamina = int256ToUint256(receiverStaminaDelta);
      require(senderEnergy == receiverStamina, "Sender energy must equal receiver stamina");
      uint256 currentSenderEnergy = Energy.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      require(currentSenderEnergy >= senderEnergy, "Sender does not have enough energy");
      Energy.set(callerAddress, senderEntity.scale, senderEntity.entityId, currentSenderEnergy - senderEnergy);
      uint256 currentReceiverStamina = Stamina.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);
      Stamina.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        currentReceiverStamina + receiverStamina
      );
    }
  }

  function updateStaminaFromStamina(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderStaminaDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    int256 receiverStaminaDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = hasKey(
      StaminaTableId,
      Stamina.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
    );
    require(entityExists, "Sender entity does not exist");
    if (isEntityEqual(senderEntity, receiverEntity)) {
      revert("You can't convert your own stamina to stamina");
    } else {
      require(receiverStaminaDelta > 0, "Cannot decrease someone's stamina");
      require(senderStaminaDelta < 0, "Cannot increase your own stamina");
      uint256 senderStamina = int256ToUint256(receiverStaminaDelta);
      uint256 receiverStamina = int256ToUint256(receiverStaminaDelta);
      require(senderStamina == receiverStamina, "Sender stamina must equal receiver stamina");

      uint256 currentSenderStamina = Stamina.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      require(currentSenderStamina >= senderStamina, "Not enough stamina to transfer");
      bool receiverEntityExists = hasKey(
        MassTableId,
        Mass.encodeKeyTuple(callerAddress, receiverEntity.scale, receiverEntity.entityId)
      );
      if (!receiverEntityExists) {
        receiverEntity = createTerrainEntity(callerAddress, receiverEntity.scale, receiverCoord);
        receiverEntityExists = hasKey(
          EnergyTableId,
          Mass.encodeKeyTuple(callerAddress, receiverEntity.scale, receiverEntity.entityId)
        );
      }
      require(receiverEntityExists, "Receiver entity does not exist");
      uint256 currentReceiverStamina = Stamina.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);
      Stamina.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        currentReceiverStamina + receiverStamina
      );
      Stamina.set(callerAddress, senderEntity.scale, senderEntity.entityId, currentSenderStamina - senderStamina);
    }
  }
}
