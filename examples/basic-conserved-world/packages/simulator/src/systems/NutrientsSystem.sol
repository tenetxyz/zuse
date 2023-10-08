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
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity } from "@tenet-simulator/src/Utils.sol";
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
}
