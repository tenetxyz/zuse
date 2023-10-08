// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { Nutrients, NutrientsTableId, SimSelectors, Health, HealthTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity, createTerrainEntity } from "@tenet-simulator/src/Utils.sol";
import { console } from "forge-std/console.sol";

contract NutrientsSystem is SimHandler {
  function registerNutrientsSelectors() public {
    SimSelectors.set(
      SimTable.Energy,
      SimTable.Nutrients,
      IWorld(_world()).updateNutrientsFromEnergy.selector,
      ValueType.Int256,
      ValueType.Int256
    );
    SimSelectors.set(
      SimTable.Nutrients,
      SimTable.Nutrients,
      IWorld(_world()).updateNutrientsFromNutrients.selector,
      ValueType.Int256,
      ValueType.Int256
    );
  }

  function updateNutrientsFromEnergy(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderEnergyDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    int256 receiverNutrientsDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = hasKey(
      EnergyTableId,
      Energy.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
    );
    require(entityExists, "Sender entity does not exist");
    if (isEntityEqual(senderEntity, receiverEntity)) {
      require(receiverNutrientsDelta > 0, "Cannot decrease your own nutrients");
      require(senderEnergyDelta < 0, "Cannot increase your own energy");
      uint256 senderEnergy = int256ToUint256(senderEnergyDelta);
      uint256 receiverNutrients = int256ToUint256(receiverNutrientsDelta);
      // TODO: Use NPK to figure out how much nutrients to convert, right now it's 1:1
      require(senderEnergy == receiverNutrients, "Sender energy must equal receiver nutrients");
      uint256 currentSenderEnergy = Energy.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      require(currentSenderEnergy >= senderEnergy, "Sender does not have enough energy");
      Energy.set(callerAddress, senderEntity.scale, senderEntity.entityId, currentSenderEnergy - senderEnergy);
      uint256 currentReceiverNutrients = Nutrients.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);
      Nutrients.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        currentReceiverNutrients + receiverNutrients
      );
    } else {
      revert("You can't convert other's energy to nutrients");
    }
  }

  function updateNutrientsFromNutrients(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderNutrientsDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    int256 receiverNutrientsDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = hasKey(
      NutrientsTableId,
      Nutrients.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
    );
    require(entityExists, "Sender entity does not exist");
    if (isEntityEqual(senderEntity, receiverEntity)) {
      revert("You can't convert your own nutrients to nutrients");
    } else {
      require(receiverNutrientsDelta > 0, "Cannot decrease someone's nutrients");
      require(senderNutrientsDelta < 0, "Cannot increase your own nutrients");
      uint256 senderNutrients = int256ToUint256(receiverNutrientsDelta);
      uint256 receiverNutrients = int256ToUint256(receiverNutrientsDelta);
      // TODO: Use NPK to figure out how much nutrients to convert, right now it's 1:1
      require(senderNutrients == receiverNutrients, "Sender nutrients must equal receiver nutrients");

      uint256 currentSenderNutrients = Nutrients.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      require(currentSenderNutrients >= senderNutrients, "Not enough nutrients to transfer");
      bool nutrientsReceiverEntityExists = hasKey(
        MassTableId,
        Mass.encodeKeyTuple(callerAddress, receiverEntity.scale, receiverEntity.entityId)
      );
      if (!energyReceiverEntityExists) {
        receiverEntity = createTerrainEntity(callerAddress, receiverEntity.scale, receiverCoord);
        nutrientsReceiverEntityExists = hasKey(
          EnergyTableId,
          Mass.encodeKeyTuple(callerAddress, receiverEntity.scale, receiverEntity.entityId)
        );
      }
      require(nutrientsReceiverEntityExists, "Receiver entity does not exist");
      uint256 currentReceiverNutrients = Nutrients.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);
      Nutrients.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        currentReceiverNutrients + receiverNutrients
      );
      Nutrients.set(callerAddress, senderEntity.scale, senderEntity.entityId, currentSenderNutrients - senderNutrients);
    }
  }
}
