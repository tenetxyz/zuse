// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { Nitrogen, NitrogenTableId, Potassium, PotassiumTableId, Phosphorous, PhosphorousTableId, Protein, ProteinTableId, Elixir, ElixirTableId, Nutrients, NutrientsTableId, SimSelectors, Health, HealthTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { int256ToUint256, addUint256AndInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity, createTerrainEntity } from "@tenet-simulator/src/Utils.sol";
import { console } from "forge-std/console.sol";

contract ProteinSystem is SimHandler {
  function registerProteinSelectors() public {
    SimSelectors.set(
      SimTable.Nutrients,
      SimTable.Protein,
      IWorld(_world()).updateProteinFromNutrients.selector,
      ValueType.Int256,
      ValueType.Int256
    );
  }

  function updateProteinFromNutrients(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderNutrientsDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    int256 receiverProteinDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = hasKey(
      NutrientsTableId,
      Nutrients.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
    );
    require(entityExists, "Sender entity does not exist");
    if (isEntityEqual(senderEntity, receiverEntity)) {
      revert("You can't convert your own nutrients to protein");
    } else {
      require(receiverProteinDelta > 0, "Cannot decrease someone's protein");
      require(senderNutrientsDelta < 0, "Cannot increase your own nutrients");
      uint256 senderNutrients = int256ToUint256(senderNutrientsDelta);
      uint256 receiverProtein = int256ToUint256(receiverProteinDelta);
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
      {
        uint256 senderNPK = Nitrogen.get(callerAddress, senderEntity.scale, senderEntity.entityId) +
          Phosphorous.get(callerAddress, senderEntity.scale, senderEntity.entityId) +
          Potassium.get(callerAddress, senderEntity.scale, senderEntity.entityId);

        uint256 actualTransfer = (senderNutrients * senderNPK) / (180);
        actualTransfer =
          (actualTransfer * Nitrogen.get(callerAddress, senderEntity.scale, senderEntity.entityId)) /
          (40); //if they have lower than 40 P, its bad; else its good

        uint256 ninetyFivePercent = (senderNutrients * 95) / 100;

        if (actualTransfer > ninetyFivePercent) {
          actualTransfer = ninetyFivePercent;
        }

        receiverProtein = actualTransfer;
      }
      if (receiverProtein == 0) {
        return;
      }
      require(senderNutrients >= receiverProtein, "Not enough energy to nutrients to convert to protein");

      uint256 currentSenderNutrients = Nutrients.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      require(currentSenderNutrients >= senderNutrients, "Not enough nutrients to transfer");
      {
        bool receiverEntityExists = Mass.getHasValue(callerAddress, receiverEntity.scale, receiverEntity.entityId);
        if (!receiverEntityExists) {
          receiverEntity = createTerrainEntity(callerAddress, receiverEntity.scale, receiverCoord);
          receiverEntityExists = Mass.getHasValue(callerAddress, receiverEntity.scale, receiverEntity.entityId);
        }
        require(receiverEntityExists, "Receiver entity does not exist");
      }
      Protein.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        Protein.get(callerAddress, receiverEntity.scale, receiverEntity.entityId) + receiverProtein
      );
      Nutrients.set(callerAddress, senderEntity.scale, senderEntity.entityId, currentSenderNutrients - senderNutrients);

      {
        uint256 nutrients_cost = senderNutrients - receiverProtein;
        if (nutrients_cost > 0) {
          IWorld(_world()).fluxEnergy(false, callerAddress, senderEntity, nutrients_cost);
        }
      }
    }
  }

  function updateProteinFromEnergy(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderEnergyDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    int256 receiverProteinDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = Energy.getHasValue(callerAddress, senderEntity.scale, senderEntity.entityId);
    require(entityExists, "Sender entity does not exist");
    require(_msgSender() == _world(), "Only the world can update protein from energy");
    if ((senderEnergyDelta > 0 && receiverProteinDelta > 0) || (senderEnergyDelta < 0 && receiverProteinDelta < 0)) {
      revert("Sender energy delta and receiver elixir delta must have opposite signs");
    }
    if (isEntityEqual(senderEntity, receiverEntity)) {
      uint256 senderEnergy = int256ToUint256(senderEnergyDelta);
      uint256 receiverProtein = int256ToUint256(receiverProteinDelta);
      require(senderEnergy == receiverProtein, "Sender energy must equal receiver protein");
      uint256 currentSenderEnergy = Energy.getEnergy(callerAddress, senderEntity.scale, senderEntity.entityId);
      if (senderEnergyDelta < 0) {
        require(currentSenderEnergy >= senderEnergy, "Sender does not have enough energy");
      }
      Energy.set(
        callerAddress,
        senderEntity.scale,
        senderEntity.entityId,
        addUint256AndInt256(currentSenderEnergy, senderEnergyDelta),
        true
      );
      uint256 currentReceiverProtein = Protein.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);
      if (receiverProteinDelta < 0) {
        require(currentReceiverProtein >= receiverProtein, "Receiver does not have enough protein");
      }
      Protein.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        addUint256AndInt256(currentReceiverProtein, receiverProteinDelta)
      );
    } else {
      revert("You can't convert other's energy to protein");
    }
  }
}
