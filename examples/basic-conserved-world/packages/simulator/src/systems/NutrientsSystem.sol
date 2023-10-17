// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { Nitrogen, NitrogenTableId, Potassium, PotassiumTableId, Phosphorous, PhosphorousTableId, Nutrients, NutrientsTableId, SimSelectors, Health, HealthTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { safeSubtract, int256ToUint256, addUint256AndInt256, uint256ToInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { absoluteDifference } from "@tenet-utils/src/MathUtils.sol";
import { getNeighbourEntities } from "@tenet-simulator/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity, createTerrainEntity } from "@tenet-simulator/src/Utils.sol";
import { console } from "forge-std/console.sol";

uint256 constant NUTRIENT_TRANSFER_MAX_DELTA = 50;

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

  function getNutrientsDelta(
    address callerAddress,
    VoxelEntity memory senderEntity,
    uint256 senderEnergy
  ) internal view returns (int256) {
    uint256 mass = Mass.get(callerAddress, senderEntity.scale, senderEntity.entityId);
    require(mass > 0, "Sender entity mass must be greater than 0");

    (bytes32[] memory neighbourEntities, ) = getNeighbourEntities(callerAddress, senderEntity);

    uint256 totalNutrients = 0;
    uint256 totalMass = 0;
    uint256 numNeighbours = 0;
    uint256 numNutrientNeighbours = 0;

    for (uint8 i = 0; i < neighbourEntities.length; i++) {
      if (uint256(neighbourEntities[i]) != 0) {
        if (
          hasKey(NutrientsTableId, Nutrients.encodeKeyTuple(callerAddress, senderEntity.scale, neighbourEntities[i]))
        ) {
          numNutrientNeighbours++;
          uint256 neighborNutrients = Nutrients.get(callerAddress, senderEntity.scale, neighbourEntities[i]);
          totalNutrients += neighborNutrients;
        }

        uint256 neighborMass = Mass.get(callerAddress, senderEntity.scale, neighbourEntities[i]);
        totalMass += neighborMass;
        numNeighbours++;
      }
    }

    uint256 selfNutrients = Nutrients.get(callerAddress, senderEntity.scale, senderEntity.entityId);
    uint256 newSelfNutrients = senderEnergy + selfNutrients;
    uint256 actualEnergyToConvert = newSelfNutrients;
    if (numNeighbours == 0 || numNutrientNeighbours == 0) {
      return int256(actualEnergyToConvert);
    }

    uint256 averageNutrients = totalNutrients / numNutrientNeighbours;
    uint256 averageMass = totalMass / numNeighbours;

    uint256 massFactor = 100; // start with 100%, i.e., no change
    if (mass > averageMass) {
      uint256 massDifference = mass - averageMass;
      uint256 massPercentAboveAverage = (massDifference * 100) / averageMass;
      massFactor = safeSubtract(100, massPercentAboveAverage); // This will reduce the lossFactor
    }

    // do an absolute
    uint256 difference = absoluteDifference(averageNutrients, newSelfNutrients);
    uint256 lossFactor = (difference * newSelfNutrients) / 100;
    lossFactor = (lossFactor * massFactor) / 100; // Adjust loss factor based on mass
    actualEnergyToConvert -= lossFactor;

    return int256(actualEnergyToConvert);
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
    {
      bool entityExists = hasKey(
        EnergyTableId,
        Energy.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
      );
      require(entityExists, "Sender entity does not exist");
    }
    if (
      (senderEnergyDelta > 0 && receiverNutrientsDelta > 0) || (senderEnergyDelta < 0 && receiverNutrientsDelta < 0)
    ) {
      revert("Sender energy delta and receiver elixir delta must have opposite signs");
    }
    if (isEntityEqual(senderEntity, receiverEntity)) {
      uint256 senderEnergy = int256ToUint256(senderEnergyDelta);
      uint256 receiverNutrients = int256ToUint256(receiverNutrientsDelta);
      uint256 e_cost = 0;
      if (_msgSender() != _world()) {
        require(receiverNutrientsDelta > 0, "Cannot decrease your own nutrients");
        require(senderEnergyDelta < 0, "Cannot increase your own energy");
        receiverNutrientsDelta = getNutrientsDelta(callerAddress, senderEntity, senderEnergy);
        console.log("receiverNutrientsDelta");
        console.logInt(receiverNutrientsDelta);
        if (receiverNutrientsDelta == 0) {
          return;
        }
        require(senderEnergy >= int256ToUint256(receiverNutrientsDelta), "Not enough energy to convert to nutrients");
        e_cost = senderEnergy - int256ToUint256(receiverNutrientsDelta);
      } else {
        require(senderEnergy == receiverNutrients, "Sender energy must equal receiver nutrients");
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
      uint256 currentReceiverNutrients = Nutrients.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);
      if (receiverNutrientsDelta < 0) {
        require(currentReceiverNutrients >= receiverNutrients, "Receiver does not have enough nutrients");
      }
      Nutrients.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        addUint256AndInt256(currentReceiverNutrients, receiverNutrientsDelta)
      );

      if (e_cost > 0) {
        IWorld(_world()).fluxEnergy(false, callerAddress, receiverEntity, e_cost);
      }
    } else {
      revert("You can't convert other's energy to nutrients");
    }
  }

  function calcReceiverNutrients(
    address callerAddress,
    VoxelEntity memory senderEntity,
    VoxelEntity memory receiverEntity,
    uint256 senderNutrients
  ) internal returns (uint256) {
    uint256 senderNPK = Nitrogen.get(callerAddress, senderEntity.scale, senderEntity.entityId) +
      Phosphorous.get(callerAddress, senderEntity.scale, senderEntity.entityId) +
      Potassium.get(callerAddress, senderEntity.scale, senderEntity.entityId);
    uint256 receiverNPK = Nitrogen.get(callerAddress, receiverEntity.scale, receiverEntity.entityId) +
      Phosphorous.get(callerAddress, receiverEntity.scale, receiverEntity.entityId) +
      Potassium.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);

    // Calculate the actual transfer amount
    uint256 actualTransfer = (senderNutrients * senderNPK * receiverNPK) / (14000);

    uint256 ninetyFivePercent = (senderNutrients * 95) / 100;
    if (actualTransfer > ninetyFivePercent) {
      actualTransfer = ninetyFivePercent;
    }

    return actualTransfer;
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
    {
      bool entityExists = hasKey(
        NutrientsTableId,
        Nutrients.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
      );
      require(entityExists, "Sender entity does not exist");
    }
    if (isEntityEqual(senderEntity, receiverEntity)) {
      revert("You can't convert your own nutrients to nutrients");
    } else {
      require(receiverNutrientsDelta > 0, "Cannot decrease someone's nutrients");
      require(senderNutrientsDelta < 0, "Cannot increase your own nutrients");
      uint256 senderNutrients = int256ToUint256(receiverNutrientsDelta);
      uint256 receiverNutrients = int256ToUint256(receiverNutrientsDelta);
      require(
        hasKey(NitrogenTableId, Nitrogen.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)),
        "Sender entity does not have nitrogen"
      );
      require(
        hasKey(
          PhosphorousTableId,
          Phosphorous.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
        ),
        "Sender entity does not have phosphorous"
      );
      require(
        hasKey(PotassiumTableId, Potassium.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)),
        "Sender entity does not have potassium"
      );
      require(
        hasKey(NitrogenTableId, Nitrogen.encodeKeyTuple(callerAddress, receiverEntity.scale, receiverEntity.entityId)),
        "Sender entity does not have nitrogen"
      );
      require(
        hasKey(
          PhosphorousTableId,
          Phosphorous.encodeKeyTuple(callerAddress, receiverEntity.scale, receiverEntity.entityId)
        ),
        "Sender entity does not have phosphorous"
      );
      require(
        hasKey(
          PotassiumTableId,
          Potassium.encodeKeyTuple(callerAddress, receiverEntity.scale, receiverEntity.entityId)
        ),
        "Sender entity does not have potassium"
      );

      //sender, receiver nutrient energy check
      uint256 currentSenderNutrients = Nutrients.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      require(currentSenderNutrients >= senderNutrients, "Not enough nutrients to transfer");

      require(
        hasKey(
          NutrientsTableId,
          Nutrients.encodeKeyTuple(callerAddress, receiverEntity.scale, receiverEntity.entityId)
        ),
        "Not a nutrient-holding cell"
      );
      uint256 currentReceiverNutrients = Nutrients.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);

      require(
        absoluteDifference(currentSenderNutrients, currentReceiverNutrients) <= NUTRIENT_TRANSFER_MAX_DELTA,
        "Can't transfer from high to low if there's a large difference"
      );

      receiverNutrients = calcReceiverNutrients(callerAddress, senderEntity, receiverEntity, senderNutrients);
      if (receiverNutrients == 0) {
        return;
      }
      require(senderNutrients >= receiverNutrients, "Not enough energy to nutrients to sender");

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
      Nutrients.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        currentReceiverNutrients + receiverNutrients
      );
      Nutrients.set(callerAddress, senderEntity.scale, senderEntity.entityId, currentSenderNutrients - senderNutrients);
      {
        uint256 nutrients_cost = senderNutrients - receiverNutrients;
        if (nutrients_cost > 0) {
          IWorld(_world()).fluxEnergy(false, callerAddress, senderEntity, nutrients_cost);
        }
      }
    }
  }
}
