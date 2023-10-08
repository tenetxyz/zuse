// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { SimSelectors, Health, HealthTableId, Stamina, StaminaTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord, int256ToUint256 } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity } from "@tenet-simulator/src/Utils.sol";
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
}
