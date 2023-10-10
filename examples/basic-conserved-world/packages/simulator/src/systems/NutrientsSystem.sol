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
import { int256ToUint256, addUint256AndInt256, uint256ToInt256 } from "@tenet-utils/src/TypeUtils.sol";
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

  function getNutrientsDelta(
    address callerAddress,
    VoxelEntity memory senderEntity,
    uint256 senderEnergy
  ) internal view returns (int256) {
    require(
      hasKey(NitrogenTableId, Nitrogen.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)),
      "Sender entity does not have nitrogen"
    );
    require(
      hasKey(PhosphorousTableId, Phosphorous.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)),
      "Sender entity does not have phosphorous"
    );
    require(
      hasKey(PotassiumTableId, Potassium.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)),
      "Sender entity does not have potassium"
    );

    uint256 mass = Mass.get(callerAddress, senderEntity.scale, senderEntity.entityId);
    require(mass > 0, "Sender entity mass must be greater than 0");
    uint256 nitrogen = Nitrogen.get(callerAddress, senderEntity.scale, senderEntity.entityId);
    uint256 phosphorus = Phosphorous.get(callerAddress, senderEntity.scale, senderEntity.entityId);
    uint256 potassium = Potassium.get(callerAddress, senderEntity.scale, senderEntity.entityId);
    // calculate nutrients from energy
    // e_cost = 1/m * (n * p * k) * receiverNutrientsDelta
    // e_net = receiverNutrientsDelta + e_cost
    return uint256ToInt256(senderEnergy / (1 + ((nitrogen * phosphorus * potassium) / mass)));
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
        require(int256ToUint256(receiverNutrientsDelta) >= senderEnergy, "Not enough energy to convert to nutrients");
        e_cost = senderEnergy - int256ToUint256(receiverNutrientsDelta);
      } else {
        require(senderEnergy == receiverNutrients, "Sender energy must equal receiver nutrients");
      }

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
      {
        uint256 senderNPK = Nitrogen.get(callerAddress, senderEntity.scale, senderEntity.entityId) +
          Phosphorous.get(callerAddress, senderEntity.scale, senderEntity.entityId) +
          Potassium.get(callerAddress, senderEntity.scale, senderEntity.entityId);
        uint256 receiverNPK = Nitrogen.get(callerAddress, receiverEntity.scale, receiverEntity.entityId) +
          Phosphorous.get(callerAddress, receiverEntity.scale, receiverEntity.entityId) +
          Potassium.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);
        require(receiverNPK >= senderNPK, "Receiver NPK must be greater than or equal to sender NPK");
      }
      receiverNutrients =
        senderNutrients /
        (1 + (1 / Mass.get(callerAddress, senderEntity.scale, senderEntity.entityId)));
      if (receiverNutrients == 0) {
        return;
      }
      require(senderNutrients >= receiverNutrients, "Not enough energy to nutrients to sender");

      uint256 currentSenderNutrients = Nutrients.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      require(currentSenderNutrients >= senderNutrients, "Not enough nutrients to transfer");
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
        Nutrients.get(callerAddress, receiverEntity.scale, receiverEntity.entityId) + receiverNutrients
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