// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { Elixir, ElixirTableId, SimSelectors, Health, HealthTableId, HealthData, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { int256ToUint256, addUint256AndInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity, createTerrainEntity } from "@tenet-simulator/src/Utils.sol";
import { console } from "forge-std/console.sol";

contract HealthSystem is SimHandler {
  function registerHealthSelectors() public {
    SimSelectors.set(
      SimTable.Elixir,
      SimTable.Health,
      IWorld(_world()).updateHealthFromElixir.selector,
      ValueType.Int256,
      ValueType.Int256
    );

    SimSelectors.set(
      SimTable.Health,
      SimTable.Health,
      IWorld(_world()).updateHealthFromHealth.selector,
      ValueType.Int256,
      ValueType.Int256
    );
  }

  function updateHealthFromElixir(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderElixirDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    int256 receiverHealthDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = hasKey(
      ElixirTableId,
      Elixir.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
    );
    require(entityExists, "Sender entity does not exist");
    if (isEntityEqual(senderEntity, receiverEntity)) {
      revert("You can't convert your own elixir to health");
    } else {
      require(receiverHealthDelta > 0, "Cannot decrease others health");
      require(senderElixirDelta < 0, "Cannot increase your own elixir");
      uint256 senderElixir = int256ToUint256(senderElixirDelta);
      uint256 receiverHealth = int256ToUint256(receiverHealthDelta);
      require(senderElixir == receiverHealth, "Sender elixir must equal receiver health");
      uint256 currentSenderElixir = Elixir.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      require(currentSenderElixir >= senderElixir, "Sender does not have enough elixir");
      Elixir.set(callerAddress, senderEntity.scale, senderEntity.entityId, currentSenderElixir - senderElixir);
      uint256 currentReceiverHealth = Health.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);
      Health.set(callerAddress, receiverEntity.scale, receiverEntity.entityId, currentReceiverHealth + receiverHealth);
    }
  }

  function updateHealthFromEnergy(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderEnergyDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    int256 receiverHealthDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = hasKey(
      EnergyTableId,
      Energy.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
    );
    require(entityExists, "Sender entity does not exist");
    require(_msgSender() == _world(), "Only the world can update health from energy");
    if ((senderEnergyDelta > 0 && receiverHealthDelta > 0) || (senderEnergyDelta < 0 && receiverHealthDelta < 0)) {
      revert("Sender energy delta and receiver elixir delta must have opposite signs");
    }
    if (isEntityEqual(senderEntity, receiverEntity)) {
      uint256 senderEnergy = int256ToUint256(senderEnergyDelta);
      uint256 receiverHealth = int256ToUint256(receiverHealthDelta);
      require(senderEnergy == receiverHealth, "Sender energy must equal receiver health");
      uint256 currentSenderEnergy = Energy.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      if (senderEnergyDelta < 0) {
        require(currentSenderEnergy >= senderEnergy, "Sender does not have enough energy");
      }
      Energy.set(
        callerAddress,
        senderEntity.scale,
        senderEntity.entityId,
        addUint256AndInt256(currentSenderEnergy, senderEnergyDelta)
      );
      uint256 currentReceiverHealth = Health.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);
      if (receiverHealthDelta < 0) {
        require(currentReceiverHealth >= receiverHealth, "Receiver does not have enough health");
      }
      Health.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        addUint256AndInt256(currentReceiverHealth, receiverHealthDelta)
      );
    } else {
      revert("You can't convert other's energy to health");
    }
  }

  function updateHealthFromHealth(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderHealthDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    int256 receiverHealthDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = hasKey(
      HealthTableId,
      Health.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
    );
    require(entityExists, "Sender entity does not exist");
    if (isEntityEqual(senderEntity, receiverEntity)) {
      revert("You can't convert your own health to health");
    } else {
      require(receiverHealthDelta > 0, "Cannot decrease someone's health");
      require(senderHealthDelta < 0, "Cannot increase your own health");
      uint256 senderHealth = int256ToUint256(receiverHealthDelta);
      uint256 receiverHealth = int256ToUint256(receiverHealthDelta);
      require(senderHealth == receiverHealth, "Sender health must equal receiver health");

      uint256 currentSenderHealth = Health.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      require(currentSenderHealth >= senderHealth, "Not enough health to transfer");
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
      uint256 currentReceiverHealth = Health.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);
      Health.set(callerAddress, receiverEntity.scale, receiverEntity.entityId, currentReceiverHealth + receiverHealth);
      Health.set(callerAddress, senderEntity.scale, senderEntity.entityId, currentSenderHealth - senderHealth);
    }
  }
}
