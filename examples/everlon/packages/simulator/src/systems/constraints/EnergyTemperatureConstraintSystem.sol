// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Constraint } from "@tenet-base-simulator/src/prototypes/Constraint.sol";

import { SimAction } from "@tenet-simulator/src/codegen/tables/SimAction.sol";
import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy, EnergyTableId } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Stamina, StaminaTableId } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Temperature, TemperatureTableId } from "@tenet-simulator/src/codegen/tables/Temperature.sol";

import { absoluteDifference } from "@tenet-utils/src/MathUtils.sol";
import { getEntityIdFromObjectEntityId, getVonNeumannNeighbourEntities } from "@tenet-base-world/src/Utils.sol";
import { VoxelCoord, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256, safeSubtract } from "@tenet-utils/src/TypeUtils.sol";

contract EnergyTemperatureConstraintSystem is Constraint {
  function registerEnergyTemperatureSelector() public {
    SimAction.set(
      SimTable.Energy,
      SimTable.Temperature,
      IWorld(_world()).energyTemperatureTransformation.selector,
      IWorld(_world()).energyTemperatureTransfer.selector
    );
  }

  function decodeAmounts(bytes memory fromAmount, bytes memory toAmount) internal pure returns (int256, int256) {
    return (abi.decode(fromAmount, (int256)), abi.decode(toAmount, (int256)));
  }

  function energyTemperatureTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function energyTemperatureTransfer(
    bytes32 senderObjectEntityId,
    VoxelCoord memory senderCoord,
    bytes32 receiverObjectEntityId,
    VoxelCoord memory receiverCoord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transfer(senderObjectEntityId, senderCoord, receiverObjectEntityId, receiverCoord, fromAmount, toAmount);
  }

  function transformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) internal override {
    address worldAddress = super.getCallerAddress();
    require(
      hasKey(EnergyTableId, Energy.encodeKeyTuple(worldAddress, objectEntityId)),
      "EnergyTemperatureConstraintSystem: Entity must have energy"
    );
    (int256 energyDelta, int256 temperatureDelta) = decodeAmounts(fromAmount, toAmount);
    if ((energyDelta > 0 && temperatureDelta > 0) || (energyDelta < 0 && temperatureDelta < 0)) {
      revert("EnergyTemperatureConstraintSystem: Energy delta and temperature delta must have opposite signs");
    }

    uint256 objectEnergy = int256ToUint256(energyDelta);
    uint256 objectTemperature = int256ToUint256(temperatureDelta);
    uint256 energyCost = 0;
    if (_msgSender() != _world()) {
      // only the world can convert nutrients back into energy
      require(temperatureDelta > 0, "EnergyTemperatureConstraintSystem: Cannot decrease your own temperature");
      require(energyDelta < 0, "EnergyTemperatureConstraintSystem: Cannot increase your own energy");
      require(
        !hasKey(StaminaTableId, Stamina.encodeKeyTuple(worldAddress, objectEntityId)),
        "EnergyTemperatureConstraintSystem: Can't have both stamina and temperature"
      );
      temperatureDelta = getTemperatureDelta(worldAddress, objectEntityId, objectEnergy);
      require(
        objectEnergy >= int256ToUint256(temperatureDelta),
        "EnergyTemperatureConstraintSystem: Not enough energy to convert to temperature"
      );
      energyCost = objectEnergy - int256ToUint256(temperatureDelta);
    } else {
      require(
        objectEnergy == objectTemperature,
        "EnergyTemperatureConstraintSystem: Object energy must equal receiver temperature"
      );
    }

    uint256 currentObjectEnergy = Energy.get(worldAddress, objectEntityId);
    if (energyDelta < 0) {
      require(
        currentObjectEnergy >= objectEnergy,
        "EnergyTemperatureConstraintSystem: Object does not have enough energy"
      );
    }
    Energy.set(worldAddress, objectEntityId, addUint256AndInt256(currentObjectEnergy, energyDelta));
    uint256 currentObjectTemperature = Temperature.get(worldAddress, objectEntityId);
    if (temperatureDelta < 0) {
      require(
        currentObjectTemperature >= objectTemperature,
        "EnergyTemperatureConstraintSystem: Receiver does not have enough temperature"
      );
    }
    Temperature.set(worldAddress, objectEntityId, addUint256AndInt256(currentObjectTemperature, temperatureDelta));

    if (energyCost > 0) {
      IWorld(_world()).fluxEnergy(false, worldAddress, objectEntityId, energyCost);
    }

    IWorld(_world()).applyTemperatureEffects(worldAddress, objectEntityId);
  }

  function getTemperatureDelta(
    address worldAddress,
    bytes32 objectEntityId,
    uint256 objectEnergy
  ) internal view returns (int256) {
    uint256 mass = Mass.get(worldAddress, objectEntityId);
    require(mass > 0, "EnergyTemperatureConstraintSystem: Entity mass must be greater than 0");

    (bytes32[] memory neighbourEntities, ) = getVonNeumannNeighbourEntities(
      IStore(worldAddress),
      getEntityIdFromObjectEntityId(IStore(worldAddress), objectEntityId)
    );

    uint256 totalTemperature = 0;
    uint256 totalMass = 0;
    uint256 numNeighbours = 0;
    uint256 numTemperatureNeighbours = 0;

    for (uint8 i = 0; i < neighbourEntities.length; i++) {
      if (uint256(neighbourEntities[i]) != 0) {
        bytes32 neighbourObjectEntityId = ObjectEntity.get(IStore(worldAddress), neighbourEntities[i]);
        if (hasKey(TemperatureTableId, Temperature.encodeKeyTuple(worldAddress, neighbourObjectEntityId))) {
          numTemperatureNeighbours++;
          uint256 neighbourTemperature = Temperature.get(worldAddress, neighbourObjectEntityId);
          totalTemperature += neighbourTemperature;
        }

        uint256 neighborMass = Mass.get(worldAddress, neighbourObjectEntityId);
        totalMass += neighborMass;
        numNeighbours++;
      }
    }

    if (numNeighbours == 0 || numTemperatureNeighbours == 0) {
      return int256(objectEnergy);
    }

    uint256 selfTemperature = Temperature.get(worldAddress, objectEntityId);
    uint256 newSelfTemperature = objectEnergy + selfTemperature;
    uint256 actualEnergyToConvert = newSelfTemperature;

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
    if (actualEnergyToConvert > objectEnergy) {
      actualEnergyToConvert = objectEnergy;
    }

    return int256(actualEnergyToConvert);
  }

  function transfer(
    bytes32 senderObjectEntityId,
    VoxelCoord memory senderCoord,
    bytes32 receiverObjectEntityId,
    VoxelCoord memory receiverCoord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) internal override {
    revert("EnergyTemperatureConstraintSystem: You can't convert your own energy to others temperature");
  }
}
