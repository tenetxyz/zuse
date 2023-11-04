// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { Object, Temperature, TemperatureTableId, Stamina, StaminaTableId, Nitrogen, NitrogenTableId, Potassium, PotassiumTableId, Phosphorous, PhosphorousTableId, Nutrients, NutrientsTableId, SimSelectors, Health, HealthData, HealthTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { ObjectType, VoxelCoord, VoxelTypeData, VoxelEntity, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { safeSubtract, int256ToUint256, addUint256AndInt256, uint256ToInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { absoluteDifference, min } from "@tenet-utils/src/MathUtils.sol";
import { getNeighbourEntities } from "@tenet-simulator/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity, createTerrainEntity } from "@tenet-simulator/src/Utils.sol";
import { console } from "forge-std/console.sol";
import { NUTRIENT_TRANSFER_MAX_DELTA } from "@tenet-simulator/src/Constants.sol";

contract TemperatureSystem is SimHandler {
  function registerTemperatureSelectors() public {
    SimSelectors.set(
      SimTable.Energy,
      SimTable.Temperature,
      IWorld(_world()).updateTemperatureFromEnergy.selector,
      ValueType.Int256,
      ValueType.Int256
    );
    SimSelectors.set(
      SimTable.Temperature,
      SimTable.Temperature,
      IWorld(_world()).updateTemperatureFromTemperature.selector,
      ValueType.Int256,
      ValueType.Int256
    );
  }

  function temperatureBehaviour(address callerAddress, VoxelEntity memory behaviourEntity) public {
    require(_msgSender() == _world(), "Only the world can update health");

    if (
      !hasKey(
        TemperatureTableId,
        Temperature.encodeKeyTuple(callerAddress, behaviourEntity.scale, behaviourEntity.entityId)
      )
    ) {
      return;
    }
    uint256 entityTemperature = Temperature.get(callerAddress, behaviourEntity.scale, behaviourEntity.entityId);

    // Get neighbours
    (bytes32[] memory neighbourEntities, ) = getNeighbourEntities(callerAddress, behaviourEntity);
    // For each neighbour, the ones that have health
    // Update health if not already updated
    for (uint i = 0; i < neighbourEntities.length; i++) {
      if (neighbourEntities[i] == 0) {
        continue;
      }

      if (!hasKey(HealthTableId, Health.encodeKeyTuple(callerAddress, behaviourEntity.scale, neighbourEntities[i]))) {
        continue;
      }

      HealthData memory healthData = Health.get(callerAddress, behaviourEntity.scale, neighbourEntities[i]);
      if (healthData.lastUpdateBlock == block.number) {
        continue;
      }

      // Check if element time is fire
      ObjectType currentType = Object.get(callerAddress, behaviourEntity.scale, neighbourEntities[i]);
      uint256 cost_e = 0;
      uint256 newHealth = healthData.health;
      uint256 newTemperature = entityTemperature;
      uint256 difference = absoluteDifference(healthData.health, entityTemperature);
      if (currentType == ObjectType.Fire) {
        uint256 minSubtract = min(entityTemperature, difference);
        newTemperature = safeSubtract(entityTemperature, minSubtract);
        newHealth = healthData.health + minSubtract;
        cost_e = minSubtract;
      } else {
        // decrease health
        uint256 minSubtract = min(healthData.health, min(entityTemperature, difference));
        newHealth = safeSubtract(healthData.health, minSubtract);
        newTemperature = safeSubtract(entityTemperature, minSubtract);
        cost_e = 2 * minSubtract;
      }
      Health.set(callerAddress, behaviourEntity.scale, neighbourEntities[i], newHealth, block.number);
      Temperature.set(callerAddress, behaviourEntity.scale, behaviourEntity.entityId, newTemperature);
      IWorld(_world()).fluxEnergy(false, callerAddress, behaviourEntity, cost_e);
    }
  }

  function getTemperatureDelta(
    address callerAddress,
    VoxelEntity memory senderEntity,
    uint256 senderEnergy
  ) internal view returns (int256) {
    uint256 mass = Mass.get(callerAddress, senderEntity.scale, senderEntity.entityId);
    require(mass > 0, "Sender entity mass must be greater than 0");

    (bytes32[] memory neighbourEntities, ) = getNeighbourEntities(callerAddress, senderEntity);

    uint256 totalTemperature = 0;
    uint256 totalMass = 0;
    uint256 numNeighbours = 0;
    uint256 numTemperatureNeighbours = 0;

    for (uint8 i = 0; i < neighbourEntities.length; i++) {
      if (uint256(neighbourEntities[i]) != 0) {
        if (
          hasKey(
            TemperatureTableId,
            Temperature.encodeKeyTuple(callerAddress, senderEntity.scale, neighbourEntities[i])
          )
        ) {
          numTemperatureNeighbours++;
          uint256 neighborTemperature = Temperature.get(callerAddress, senderEntity.scale, neighbourEntities[i]);
          totalTemperature += neighborTemperature;
        }

        uint256 neighborMass = Mass.get(callerAddress, senderEntity.scale, neighbourEntities[i]);
        totalMass += neighborMass;
        numNeighbours++;
      }
    }

    if (numNeighbours == 0 || numTemperatureNeighbours == 0) {
      console.log("no neighbour entities");
      return int256(senderEnergy);
    }

    uint256 selfTemperature = Temperature.get(callerAddress, senderEntity.scale, senderEntity.entityId);
    uint256 newSelfTemperature = senderEnergy + selfTemperature;
    uint256 actualEnergyToConvert = newSelfTemperature;
    console.log("newSelfTemperature");
    console.logUint(newSelfTemperature);

    uint256 averageTemperature = totalTemperature / numTemperatureNeighbours;
    uint256 averageMass = totalMass / numNeighbours;

    uint256 massFactor = 100; // start with 100%, i.e., no change
    if (mass > averageMass) {
      uint256 massDifference = mass - averageMass;
      uint256 massPercentAboveAverage = (massDifference * 100) / averageMass;
      massFactor = safeSubtract(100, massPercentAboveAverage); // This will reduce the lossFactor
    }

    // do an absolute
    uint256 difference = absoluteDifference(averageTemperature, newSelfTemperature);
    uint256 lossFactor = (difference * newSelfTemperature) / 100;
    lossFactor = (lossFactor * massFactor) / 100; // Adjust loss factor based on mass
    actualEnergyToConvert = safeSubtract(actualEnergyToConvert, lossFactor);
    console.log("actualEnergyToConvert");
    console.logUint(actualEnergyToConvert);
    if (actualEnergyToConvert > senderEnergy) {
      actualEnergyToConvert = senderEnergy;
    }

    return int256(actualEnergyToConvert);
  }

  function updateTemperatureFromEnergy(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderEnergyDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    int256 receiverTemperatureDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    {
      bool entityExists = hasKey(
        EnergyTableId,
        Energy.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
      );
      require(entityExists, "Sender entity does not exist");
    }
    if (
      (senderEnergyDelta > 0 && receiverTemperatureDelta > 0) || (senderEnergyDelta < 0 && receiverTemperatureDelta < 0)
    ) {
      revert("Sender energy delta and receiver elixir delta must have opposite signs");
    }
    if (isEntityEqual(senderEntity, receiverEntity)) {
      uint256 senderEnergy = int256ToUint256(senderEnergyDelta);
      uint256 receiverTemperature = int256ToUint256(receiverTemperatureDelta);
      uint256 e_cost = 0;
      if (_msgSender() != _world()) {
        require(receiverTemperatureDelta > 0, "Cannot decrease your own temperature");
        require(senderEnergyDelta < 0, "Cannot increase your own energy");
        require(
          Stamina.get(callerAddress, receiverEntity.scale, receiverEntity.entityId) == 0,
          "Can't have both stamina and temperature"
        );
        receiverTemperatureDelta = getTemperatureDelta(callerAddress, senderEntity, senderEnergy);
        console.log("receiverTemperatureDelta");
        console.logInt(receiverTemperatureDelta);
        if (receiverTemperatureDelta == 0) {
          return;
        }
        require(
          senderEnergy >= int256ToUint256(receiverTemperatureDelta),
          "Not enough energy to convert to temperature"
        );
        e_cost = senderEnergy - int256ToUint256(receiverTemperatureDelta);
      } else {
        require(senderEnergy == receiverTemperature, "Sender energy must equal receiver temperature");
      }

      uint256 currentSenderEnergy = Energy.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      if (senderEnergyDelta < 0) {
        console.log("currentSenderEnergy");
        console.logBytes32(senderEntity.entityId);
        console.logUint(currentSenderEnergy);
        console.logUint(senderEnergy);
        require(currentSenderEnergy >= senderEnergy, "Sender does not have enough energy");
      }
      Energy.set(
        callerAddress,
        senderEntity.scale,
        senderEntity.entityId,
        addUint256AndInt256(currentSenderEnergy, senderEnergyDelta)
      );
      uint256 currentReceiverTemperature = Temperature.get(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId
      );
      if (receiverTemperatureDelta < 0) {
        require(currentReceiverTemperature >= receiverTemperature, "Receiver does not have enough temperature");
      }
      Temperature.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        addUint256AndInt256(currentReceiverTemperature, receiverTemperatureDelta)
      );

      if (e_cost > 0) {
        IWorld(_world()).fluxEnergy(false, callerAddress, receiverEntity, e_cost);
      }
    } else {
      revert("You can't convert other's energy to temperature");
    }
  }

  function calcReceiverTemperature(
    address callerAddress,
    VoxelEntity memory senderEntity,
    VoxelEntity memory receiverEntity,
    uint256 senderTemperature
  ) internal returns (uint256) {
    uint256 mass = Mass.get(callerAddress, senderEntity.scale, senderEntity.entityId);

    // Calculate the actual transfer amount
    uint256 actualTransfer = (senderTemperature * mass) / (50); //50 is a high mass according to current perlin budgets

    uint256 ninetyFivePercent = (senderTemperature * 95) / 100;
    if (actualTransfer > ninetyFivePercent) {
      actualTransfer = ninetyFivePercent;
    }

    return actualTransfer;
  }

  function updateTemperatureFromTemperature(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderTemperatureDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    int256 receiverTemperatureDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    {
      bool entityExists = hasKey(
        TemperatureTableId,
        Temperature.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
      );
      console.log("senderEntity.entityId");
      console.logBytes32(senderEntity.entityId);
      require(entityExists, "Sender entity does not exist");
    }
    if (isEntityEqual(senderEntity, receiverEntity)) {
      revert("You can't convert your own temperature to temperature");
    } else {
      require(receiverTemperatureDelta > 0, "Cannot decrease someone's temperature");
      require(senderTemperatureDelta < 0, "Cannot increase your own temperature");
      require(
        Stamina.get(callerAddress, receiverEntity.scale, receiverEntity.entityId) == 0,
        "Can't have both stamina and temperature"
      );
      uint256 senderTemperature = int256ToUint256(receiverTemperatureDelta);
      uint256 receiverTemperature = int256ToUint256(receiverTemperatureDelta);

      uint256 currentSenderTemperature = Temperature.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      require(currentSenderTemperature >= senderTemperature, "Not enough temperature to transfer");
      uint256 currentReceiverTemperature = Temperature.get(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId
      );
      require(currentSenderTemperature >= currentReceiverTemperature, "Can't transfer from low to high");

      receiverTemperature = calcReceiverTemperature(callerAddress, senderEntity, receiverEntity, senderTemperature);
      console.log("receiverTemperature");
      console.logUint(currentReceiverTemperature);
      console.logUint(receiverTemperature);

      if (receiverTemperature == 0) {
        return;
      }
      require(senderTemperature >= receiverTemperature, "Not enough energy to temperature to sender");

      {
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
      }
      Temperature.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        currentReceiverTemperature + receiverTemperature
      );
      Temperature.set(
        callerAddress,
        senderEntity.scale,
        senderEntity.entityId,
        currentSenderTemperature - senderTemperature
      );
      {
        uint256 temperature_cost = senderTemperature - receiverTemperature;
        if (temperature_cost > 0) {
          IWorld(_world()).fluxEnergy(false, callerAddress, senderEntity, temperature_cost);
        }
      }
    }
  }
}
