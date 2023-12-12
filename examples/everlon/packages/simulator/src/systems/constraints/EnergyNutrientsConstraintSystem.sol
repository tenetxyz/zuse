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
import { Nitrogen, NitrogenTableId } from "@tenet-simulator/src/codegen/tables/Nitrogen.sol";
import { Phosphorus, PhosphorusTableId } from "@tenet-simulator/src/codegen/tables/Phosphorus.sol";
import { Potassium, PotassiumTableId } from "@tenet-simulator/src/codegen/tables/Potassium.sol";
import { Nutrients, NutrientsTableId } from "@tenet-simulator/src/codegen/tables/Nutrients.sol";

import { absoluteDifference } from "@tenet-utils/src/MathUtils.sol";
import { getEntityIdFromObjectEntityId, getVonNeumannNeighbourEntities } from "@tenet-base-world/src/Utils.sol";
import { VoxelCoord, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256, safeSubtract } from "@tenet-utils/src/TypeUtils.sol";
import { requireHasNPK } from "@tenet-simulator/src/Utils.sol";
import { NUTRIENT_TRANSFER_MAX_DELTA } from "@tenet-simulator/src/Constants.sol";

contract EnergyNutrientsConstraintSystem is Constraint {
  function registerEnergyNutrientsSelector() public {
    SimAction.set(
      SimTable.Energy,
      SimTable.Nutrients,
      IWorld(_world()).energyNutrientsTransformation.selector,
      IWorld(_world()).energyNutrientsTransfer.selector
    );
  }

  function decodeAmounts(bytes memory fromAmount, bytes memory toAmount) internal pure returns (int256, int256) {
    return (abi.decode(fromAmount, (int256)), abi.decode(toAmount, (int256)));
  }

  function energyNutrientsTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function energyNutrientsTransfer(
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
      "EnergyNutrientsConstraintSystem: Entity must have energy"
    );
    (int256 energyDelta, int256 nutrientsDelta) = decodeAmounts(fromAmount, toAmount);
    if ((energyDelta > 0 && nutrientsDelta > 0) || (energyDelta < 0 && nutrientsDelta < 0)) {
      revert("EnergyNutrientsConstraintSystem: Energy delta and nutrients delta must have opposite signs");
    }

    uint256 objectEnergy = int256ToUint256(energyDelta);
    uint256 objectNutrients = int256ToUint256(nutrientsDelta);
    uint256 energyCost = 0;
    if (_msgSender() != _world()) {
      // only the world can convert nutrients back into energy
      require(nutrientsDelta > 0, "EnergyNutrientsConstraintSystem: Cannot decrease your own nutrients");
      require(energyDelta < 0, "EnergyNutrientsConstraintSystem: Cannot increase your own energy");
      nutrientsDelta = getNutrientsDelta(worldAddress, objectEntityId, objectEnergy);
      require(
        objectEnergy >= int256ToUint256(nutrientsDelta),
        "EnergyNutrientsConstraintSystem: Not enough energy to convert to nutrients"
      );
      energyCost = objectEnergy - int256ToUint256(nutrientsDelta);
    } else {
      require(
        objectEnergy == objectNutrients,
        "EnergyNutrientsConstraintSystem: Object energy must equal receiver nutrients"
      );
    }

    uint256 currentObjectEnergy = Energy.get(worldAddress, objectEntityId);
    if (energyDelta < 0) {
      require(
        currentObjectEnergy >= objectEnergy,
        "EnergyNutrientsConstraintSystem: Object does not have enough energy"
      );
    }
    Energy.set(worldAddress, objectEntityId, addUint256AndInt256(currentObjectEnergy, energyDelta));
    uint256 currentObjectNutrients = Nutrients.get(worldAddress, objectEntityId);
    if (nutrientsDelta < 0) {
      require(
        currentObjectNutrients >= objectNutrients,
        "EnergyNutrientsConstraintSystem: Receiver does not have enough nutrients"
      );
    }
    Nutrients.set(worldAddress, objectEntityId, addUint256AndInt256(currentObjectNutrients, nutrientsDelta));

    if (energyCost > 0) {
      IWorld(_world()).fluxEnergy(false, worldAddress, objectEntityId, energyCost);
    }
  }

  function getNutrientsDelta(
    address worldAddress,
    bytes32 objectEntityId,
    uint256 objectEnergy
  ) internal view returns (int256) {
    uint256 mass = Mass.get(worldAddress, objectEntityId);
    require(mass > 0, "EnergyNutrientsConstraintSystem: Entity mass must be greater than 0");

    (bytes32[] memory neighbourEntities, ) = getVonNeumannNeighbourEntities(
      IStore(worldAddress),
      getEntityIdFromObjectEntityId(IStore(worldAddress), objectEntityId)
    );

    uint256 totalNutrients = 0;
    uint256 totalMass = 0;
    uint256 numNeighbours = 0;
    uint256 numNutrientNeighbours = 0;

    for (uint8 i = 0; i < neighbourEntities.length; i++) {
      if (uint256(neighbourEntities[i]) != 0) {
        bytes32 neighbourObjectEntityId = ObjectEntity.get(IStore(worldAddress), neighbourEntities[i]);
        if (hasKey(NutrientsTableId, Nutrients.encodeKeyTuple(worldAddress, neighbourObjectEntityId))) {
          numNutrientNeighbours++;
          uint256 neighborNutrients = Nutrients.get(worldAddress, neighbourObjectEntityId);
          totalNutrients += neighborNutrients;
        }

        uint256 neighborMass = Mass.get(worldAddress, neighbourObjectEntityId);
        totalMass += neighborMass;
        numNeighbours++;
      }
    }

    if (numNeighbours == 0 || numNutrientNeighbours == 0) {
      return int256(objectEnergy);
    }

    uint256 selfNutrients = Nutrients.get(worldAddress, objectEntityId);
    uint256 newSelfNutrients = objectEnergy + selfNutrients;
    uint256 actualEnergyToConvert = newSelfNutrients;

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
    revert("EnergyNutrientsConstraintSystem: You can't convert your own energy to others nutrients");
  }
}
